#!/bin/bash
# Configure timezone and system locale

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

setup_timezone() {
    check_root
    print_header "Setup Timezone"

    # Default timezone
    local timezone="${1:-UTC}"

    print_stage "Setting timezone to: $timezone"
    timedatectl set-timezone "$timezone"

    print_stage "Enabling NTP synchronization"
    timedatectl set-ntp true

    print_success "Timezone configured"
    print_info "Current time settings:"
    timedatectl

    echo
    print_info "To change timezone, run:"
    echo "  timedatectl list-timezones    - List available timezones"
    echo "  timedatectl set-timezone ZONE - Set timezone"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_timezone "$@"
fi

