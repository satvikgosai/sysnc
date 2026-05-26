#!/bin/bash
# shellcheck shell=bash
#
# sysnc Installation Script for Termux
# Installs (or uninstalls) sysnc and its dependencies in Termux.

set -e

# Colors for output (disabled when stdout is not a TTY).
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

SCRIPT_NAME="sysnc"
SCRIPT_URL="https://raw.githubusercontent.com/satvikgosai/sysnc/main/sysnc"

print_status()  { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1" >&2; }

show_help() {
    cat <<EOF
sysnc installer

Usage: install.sh [OPTIONS]

Options:
  -u, --uninstall   Remove sysnc and exit
  -h, --help        Show this help message

This script must be run inside Termux on Android.
EOF
}

require_termux() {
    if [ -z "${PREFIX:-}" ] || [ ! -d "$PREFIX" ]; then
        print_error "This script is designed for Termux."
        print_error "The PREFIX environment variable is not set or does not point to a directory."
        print_error "Please run this script inside the Termux app."
        exit 1
    fi
    INSTALL_DIR="$PREFIX/bin"
}

install_dependencies() {
    print_status "Checking dependencies..."

    if command -v nc &>/dev/null; then
        print_success "netcat already installed"
        return
    fi

    print_warning "netcat not found. Installing netcat-openbsd..."
    # pkg update is best-effort: a transient network blip shouldn't abort install.
    pkg update -y || print_warning "pkg update failed; continuing with cached repo data"
    pkg install -y netcat-openbsd
    print_success "netcat installed"
}

# Validate that a downloaded file looks like the sysnc bash script.
validate_script() {
    local file="$1"
    local first_line
    first_line=$(head -n 1 "$file")
    case "$first_line" in
        '#!/bin/bash'|'#!/usr/bin/env bash')
            return 0
            ;;
        *)
            print_error "Downloaded file does not start with a bash shebang: '$first_line'"
            print_error "Refusing to install a potentially corrupted or malicious file."
            return 1
            ;;
    esac
}

download_script() {
    local dest="$1"
    print_status "Downloading sysnc from $SCRIPT_URL ..."

    if command -v curl &>/dev/null; then
        curl -fsSL "$SCRIPT_URL" -o "$dest" \
            || { print_error "curl failed to download sysnc"; return 1; }
    elif command -v wget &>/dev/null; then
        wget -qO "$dest" "$SCRIPT_URL" \
            || { print_error "wget failed to download sysnc"; return 1; }
    else
        print_error "Neither curl nor wget is installed. Install one and retry."
        return 1
    fi
}

install_sysnc() {
    local target="$INSTALL_DIR/$SCRIPT_NAME"

    if [ -e "$target" ]; then
        print_warning "Existing $target will be overwritten"
    fi

    local tmp
    tmp=$(mktemp)
    trap 'rm -f "$tmp"' EXIT

    download_script "$tmp" || exit 1
    validate_script "$tmp" || exit 1

    install -m 755 "$tmp" "$target"
    print_success "sysnc installed to $target"
}

verify_installation() {
    print_status "Verifying installation..."
    if command -v "$SCRIPT_NAME" &>/dev/null; then
        local found
        found=$(command -v "$SCRIPT_NAME")
        if [ "$found" = "$INSTALL_DIR/$SCRIPT_NAME" ]; then
            print_success "$SCRIPT_NAME is on PATH at $found"
        else
            print_warning "$SCRIPT_NAME resolves to $found (not $INSTALL_DIR/$SCRIPT_NAME)"
            print_warning "Another version may be shadowing the freshly installed one."
        fi
    else
        print_error "$SCRIPT_NAME not found on PATH"
        print_error "Try restarting Termux or check that $INSTALL_DIR is on \$PATH."
        exit 1
    fi
}

uninstall_sysnc() {
    require_termux
    local target="$INSTALL_DIR/$SCRIPT_NAME"
    if [ -e "$target" ]; then
        rm -f "$target"
        print_success "Removed $target"
    else
        print_warning "$target not found; nothing to remove"
    fi
}

main() {
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -u|--uninstall)
            uninstall_sysnc
            exit 0
            ;;
        '') ;;
        *)
            print_error "Unknown argument: $1"
            show_help
            exit 1
            ;;
    esac

    echo "=========================================="
    echo "sysnc Installation Script for Termux"
    echo "=========================================="
    echo ""

    require_termux
    install_dependencies
    install_sysnc
    verify_installation

    echo ""
    print_success "Installation complete. Run 'sysnc -h' to get started."
}

main "$@"
