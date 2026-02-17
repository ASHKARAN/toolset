#!/bin/bash
# Install essential packages for server setup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_essentials() {
    check_root
    print_header "Install Essential Packages"

    print_stage "Updating system packages"
    apt_update
    apt_upgrade

    print_stage "Installing essential packages"

    local packages=(
        # System utilities
        "htop"
        "iotop"
        "iftop"
        "ncdu"
        "tree"
        "tmux"
        "screen"

        # Network tools
        "curl"
        "wget"
        "net-tools"
        "dnsutils"
        "traceroute"
        "mtr"

        # File tools
        "zip"
        "unzip"
        "pv"
        "rsync"

        # Development tools
        "build-essential"
        "software-properties-common"

        # Security
        "fail2ban"
        "ufw"

        # Other utilities
        "vim"
        "nano"
        "jq"
        "lsof"
    )

    apt_install "${packages[@]}"

    print_success "Essential packages installed"

    echo
    print_info "Installed packages:"
    for pkg in "${packages[@]}"; do
        if dpkg -l "$pkg" &>/dev/null; then
            echo "  ✓ $pkg"
        fi
    done
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_essentials "$@"
fi

