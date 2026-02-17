#!/bin/bash
# Install Certbot for Let's Encrypt SSL certificates

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_certbot() {
    check_root
    print_header "Install Certbot (Let's Encrypt)"

    print_stage "Updating system packages"
    apt_update

    print_stage "Installing Certbot"
    apt_install certbot

    # Install nginx plugin if nginx is installed
    if command_exists nginx; then
        print_stage "Installing Nginx plugin for Certbot"
        apt_install python3-certbot-nginx
    fi

    print_success "Certbot installed successfully"
    print_info "Certbot version: $(certbot --version)"

    echo
    print_info "Usage examples:"
    echo "  certbot --nginx -d example.com          - Get cert for domain with Nginx"
    echo "  certbot certonly --standalone -d domain - Standalone mode"
    echo "  certbot renew                           - Renew all certificates"
    echo "  certbot certificates                    - List certificates"

    echo
    print_info "Auto-renewal is configured via systemd timer:"
    echo "  systemctl status certbot.timer"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_certbot "$@"
fi

