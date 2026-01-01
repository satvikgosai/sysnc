#!/bin/bash

# sysnc Installation Script for Termux
# This script installs sysnc and its dependencies in Termux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="$PREFIX/bin"
SCRIPT_NAME="sysnc"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running in Termux
check_termux() {
    if [ ! -d "$PREFIX" ]; then
        print_error "This script is designed for Termux. PREFIX directory not found."
        print_error "Please run this script in Termux environment."
        exit 1
    fi
}

# Function to check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    # Check for netcat
    if ! command -v nc &> /dev/null; then
        print_warning "netcat not found. Installing netcat-openbsd..."
        pkg update && pkg install -y netcat-openbsd
        print_success "netcat installed"
    else
        print_success "netcat already installed"
    fi
    
}

# Function to install sysnc script
install_sysnc() {
    print_status "Installing sysnc script..."

    SCRIPT_URL="https://raw.githubusercontent.com/satvikgosai/sysnc/main/sysnc"

    # Create temporary file for download
    TMP=$(mktemp)

    # Cleanup on exit
    cleanup() {
        rm -f "${TMP:-}"
    }
    trap cleanup EXIT

    print_status "Downloading sysnc script from remote repository..."

    # Try curl first, then wget
    if command -v curl >/dev/null 2>&1; then
        if ! curl -fsSL "$SCRIPT_URL" -o "$TMP"; then
            print_error "Failed to download sysnc script using curl"
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -qO "$TMP" "$SCRIPT_URL"; then
            print_error "Failed to download sysnc script using wget"
            exit 1
        fi
    else
        print_error "Neither curl nor wget is installed. Please install one of them and retry."
        exit 1
    fi

    # Install script with correct permissions
    install -m 755 "$TMP" "$INSTALL_DIR/$SCRIPT_NAME"

    print_success "sysnc script installed to $INSTALL_DIR"
}



# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    # Check if sysnc is in PATH
    if command -v sysnc &> /dev/null; then
        print_success "sysnc command is available"
    else
        print_error "sysnc command not found in PATH"
        print_error "You may need to restart your shell or run: source ~/.bashrc"
    fi
}


# Main installation process
main() {
    echo "=========================================="
    echo "sysnc Installation Script for Termux"
    echo "=========================================="
    echo ""
    
    # Check if running in Termux
    check_termux
    
    # Check and install dependencies
    check_dependencies
    
    # Install sysnc script
    install_sysnc
    
    # Verify installation
    verify_installation
}

# Run main function
main "$@"
