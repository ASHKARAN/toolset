#!/bin/bash
# Configure UFW firewall with basic rules

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

setup_firewall() {
    check_root
    print_header "Setup UFW Firewall"

    print_stage "Installing UFW"
    apt_update
    apt_install ufw

    print_stage "Setting default policies"
    ufw default deny incoming
    ufw default allow outgoing

    print_stage "Allowing SSH (port 22)"
    ufw allow ssh

    print_stage "Allowing HTTP (port 80)"
    ufw allow http

    print_stage "Allowing HTTPS (port 443)"
    ufw allow https

    print_stage "Enabling UFW"
    echo "y" | ufw enable

    print_success "Firewall configured successfully"
    print_info "Firewall status:"
    ufw status verbose

    echo
    print_info "UFW Quick Reference:"
    echo "  ufw allow <port>       - Allow a port"
    echo "  ufw deny <port>        - Deny a port"
    echo "  ufw delete allow <port>- Remove a rule"
    echo "  ufw status             - Show status"
    echo "  ufw disable            - Disable firewall"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_firewall "$@"
fi

