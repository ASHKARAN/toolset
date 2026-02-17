#!/bin/bash
# System update and upgrade

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

system_update() {
    check_root
    print_header "System Update & Upgrade"

    print_stage "Updating package lists"
    apt-get update -y

    print_stage "Upgrading packages"
    apt-get upgrade -y

    print_stage "Performing distribution upgrade"
    apt-get dist-upgrade -y

    print_stage "Removing unused packages"
    apt-get autoremove -y

    print_stage "Cleaning package cache"
    apt-get autoclean -y

    print_success "System updated successfully"

    # Check if reboot is required
    if [ -f /var/run/reboot-required ]; then
        print_warning "A system reboot is required!"
        print_info "Run 'reboot' to restart the system"
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    system_update "$@"
fi

