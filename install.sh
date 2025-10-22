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
    
    # Check if sysnc script exists
    if [ ! -f "$SCRIPT_NAME" ]; then
        print_error "sysnc script not found in current directory"
        print_error "Please run this script from the directory containing sysnc"
        exit 1
    fi
    
    # Make script executable
    chmod +x "$SCRIPT_NAME"
    
    # Copy to bin directory
    cp "$SCRIPT_NAME" "$INSTALL_DIR/"
    
    print_success "sysnc script installed to $INSTALL_DIR"
}



# Function to verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    # Check if sysnc is in PATH
    if command -v sysnc &> /dev/null; then
        print_success "sysnc command is available"
        
        # Test help command
        if sysnc --help &> /dev/null; then
            print_success "sysnc is working correctly"
        else
            print_warning "sysnc installed but may have issues"
        fi
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
