#!/bin/bash
# Install Docker and Docker Compose

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_docker() {
    check_root
    print_header "Install Docker"

    print_stage "Updating system packages"
    apt_update
    apt_upgrade

    print_stage "Removing old Docker versions"
    apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

    print_stage "Installing prerequisites"
    apt_install ca-certificates curl gnupg lsb-release

    print_stage "Setting up Docker repository"
    mkdir -m 0755 -p /etc/apt/keyrings

    # Remove old key if exists
    rm -f /etc/apt/keyrings/docker.gpg

    # Detect OS (Ubuntu or Debian)
    . /etc/os-release
    local os_id="${ID}"

    curl -fsSL "https://download.docker.com/linux/${os_id}/gpg" | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${os_id} \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null

    print_stage "Installing Docker Engine"
    apt_update
    apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Fix broken packages if any
    apt-get --fix-broken install -y > /dev/null 2>&1

    print_stage "Installing Docker Compose (standalone)"
    apt_install docker-compose

    print_stage "Configuring Docker for non-root user"
    # Add current SUDO_USER to docker group if available
    if [ -n "$SUDO_USER" ]; then
        usermod -aG docker "$SUDO_USER"
        print_info "Added $SUDO_USER to docker group"
        print_warning "Please log out and back in for group changes to take effect"
    fi

    print_stage "Starting Docker service"
    systemctl enable docker
    systemctl start docker

    print_success "Docker installed successfully"
    print_info "Docker version: $(docker --version)"
    print_info "Docker Compose version: $(docker compose version 2>/dev/null || docker-compose --version)"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_docker "$@"
fi

