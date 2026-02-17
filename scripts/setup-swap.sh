#!/bin/bash
# Configure swap space

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

setup_swap() {
    check_root
    print_header "Setup Swap Space"

    # Default swap size in GB
    local swap_size="${1:-2}"
    local swap_file="/swapfile"

    # Check if swap already exists
    if swapon --show | grep -q "$swap_file"; then
        print_warning "Swap file already exists"
        print_info "Current swap:"
        swapon --show
        return 0
    fi

    print_stage "Creating ${swap_size}G swap file"
    # Use fallocate if available, otherwise use dd (for ext3 or older systems)
    if command -v fallocate &> /dev/null && fallocate -l "${swap_size}G" "$swap_file" 2>/dev/null; then
        : # fallocate succeeded
    else
        dd if=/dev/zero of="$swap_file" bs=1M count=$((swap_size * 1024)) status=progress
    fi
    chmod 600 "$swap_file"

    print_stage "Setting up swap space"
    mkswap "$swap_file" > /dev/null
    swapon "$swap_file"

    print_stage "Making swap permanent"
    if ! grep -q "$swap_file" /etc/fstab; then
        echo "$swap_file none swap sw 0 0" >> /etc/fstab
    fi

    print_stage "Optimizing swap settings"
    # Set swappiness to 10 (less aggressive swapping)
    sysctl vm.swappiness=10 > /dev/null
    if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
        echo "vm.swappiness=10" >> /etc/sysctl.conf
    fi

    print_success "Swap configured successfully"
    print_info "Swap status:"
    swapon --show
    free -h
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_swap "$@"
fi

