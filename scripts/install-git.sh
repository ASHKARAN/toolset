#!/bin/bash
# Install Git

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_git() {
    check_root
    print_header "Install Git"

    print_stage "Updating system packages"
    apt_update

    print_stage "Installing Git"
    apt_install git

    print_success "Git installed successfully"
    print_info "Git version: $(git --version)"

    # Configure git if SUDO_USER is available
    if [ -n "$SUDO_USER" ]; then
        echo
        print_info "To configure Git globally, run:"
        echo "  git config --global user.name \"Your Name\""
        echo "  git config --global user.email \"your@email.com\""
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_git "$@"
fi

