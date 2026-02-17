#!/bin/bash
# Copy SSH key to a user's authorized_keys

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

copy_ssh_key() {
    check_root
    print_header "Copy SSH Key"

    # Get username
    if [ -z "$1" ]; then
        read -p "Enter target username: " target_user
    else
        target_user="$1"
    fi

    # Check if user exists
    if ! id "$target_user" &>/dev/null; then
        print_error "User '$target_user' does not exist"
        return 1
    fi

    # Get SSH key
    if [ -z "$2" ]; then
        echo "Enter SSH public key (paste and press Enter):"
        read -r ssh_key
    else
        ssh_key="$2"
    fi

    if [ -z "$ssh_key" ]; then
        print_error "SSH key is required"
        return 1
    fi

    # Ensure .ssh directory exists
    local ssh_dir="/home/$target_user/.ssh"
    local auth_keys="$ssh_dir/authorized_keys"

    print_stage "Setting up SSH directory"
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"

    # Check if key already exists
    if grep -qF "$ssh_key" "$auth_keys" 2>/dev/null; then
        print_warning "SSH key already exists in authorized_keys"
        return 0
    fi

    print_stage "Adding SSH key"
    echo "$ssh_key" >> "$auth_keys"
    chmod 600 "$auth_keys"
    chown -R $target_user:$target_user "$ssh_dir"

    print_success "SSH key added for user '$target_user'"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    copy_ssh_key "$@"
fi

