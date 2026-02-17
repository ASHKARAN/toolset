#!/bin/bash
# Create a new user with sudo privileges and SSH setup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

create_user() {
    check_root
    print_header "Create New User"

    # Get username
    if [ -z "$1" ]; then
        read -p "Enter username: " new_username
    else
        new_username="$1"
    fi

    # Get password
    if [ -z "$2" ]; then
        read -s -p "Enter password: " new_password
        echo
    else
        new_password="$2"
    fi

    # Validate inputs
    if [ -z "$new_username" ] || [ -z "$new_password" ]; then
        print_error "Username and password are required"
        return 1
    fi

    # Check if user already exists
    if id "$new_username" &>/dev/null; then
        print_warning "User '$new_username' already exists"
        return 1
    fi

    print_stage "Creating user: $new_username"
    adduser --disabled-password --gecos "" "$new_username" > /dev/null 2>&1

    print_stage "Setting password"
    echo "$new_username:$new_password" | chpasswd

    print_stage "Adding to sudo group"
    usermod -aG sudo "$new_username"

    print_stage "Setting up SSH directory"
    mkdir -p /home/$new_username/.ssh
    touch /home/$new_username/.ssh/authorized_keys
    chmod 700 /home/$new_username/.ssh
    chmod 600 /home/$new_username/.ssh/authorized_keys
    chown -R $new_username:$new_username /home/$new_username/.ssh

    print_success "User '$new_username' created successfully"
    print_info "SSH authorized_keys file: /home/$new_username/.ssh/authorized_keys"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_user "$@"
fi

