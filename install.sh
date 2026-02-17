#!/bin/bash
#===============================================================================
#
#   DevOps Toolset - One-Line Installer
#
#   Usage:
#     curl -fsSL https://raw.githubusercontent.com/ASHKARAN/toolset/main/install.sh | bash
#     wget -qO- https://raw.githubusercontent.com/ASHKARAN/toolset/main/install.sh | bash
#
#   Or with custom install directory:
#     curl -fsSL https://raw.githubusercontent.com/ASHKARAN/toolset/main/install.sh | INSTALL_DIR=/opt/toolset bash
#
#===============================================================================

set -e

# Configuration
REPO_URL="https://github.com/ASHKARAN/toolset"
RAW_URL="https://raw.githubusercontent.com/ASHKARAN/toolset/main"
INSTALL_DIR="${INSTALL_DIR:-$HOME/toolset}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
    ____             ____                ______            __         __
   / __ \___ _   __ / __ \____  _____   /_  __/___  ____  / /___ ___ / /_
  / / / / _ \ | / // / / / __ \/ ___/    / / / __ \/ __ \/ / __ `__ / __/
 / /_/ /  __/ |/ // /_/ / /_/ (__  )    / / / /_/ / /_/ / (__  /  / /_
/_____/\___/|___/ \____/ .___/____/    /_/  \____/\____/_/____/   \__/
                      /_/
EOF
    echo -e "${NC}"
    echo -e "${BLUE}Server Setup Toolset - One-Line Installer${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

print_success() { echo -e "${GREEN}[✓] $1${NC}"; }
print_error() { echo -e "${RED}[✗] $1${NC}"; }
print_info() { echo -e "${BLUE}[i] $1${NC}"; }
print_stage() { echo -e "${YELLOW}>>> $1${NC}"; }

# Check for required commands
check_requirements() {
    local missing=()

    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        missing+=("curl or wget")
    fi

    if ! command -v git &> /dev/null; then
        # Git not required if we use curl/wget to download files
        print_info "Git not found, will download files directly"
        USE_GIT=false
    else
        USE_GIT=true
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing[*]}"
        exit 1
    fi
}

# Download using curl or wget
download() {
    local url="$1"
    local output="$2"

    if command -v curl &> /dev/null; then
        curl -fsSL "$url" -o "$output"
    elif command -v wget &> /dev/null; then
        wget -qO "$output" "$url"
    fi
}

# Install using git clone
install_with_git() {
    print_stage "Cloning repository..."

    if [ -d "$INSTALL_DIR" ]; then
        print_info "Directory exists, updating..."
        cd "$INSTALL_DIR"
        git pull --quiet
    else
        git clone --quiet "$REPO_URL" "$INSTALL_DIR"
    fi
}

# Install by downloading individual files
install_with_download() {
    print_stage "Downloading toolset files..."

    # Create directories
    mkdir -p "$INSTALL_DIR/scripts"

    # List of files to download
    local main_files=(
        "setup.sh"
        "README.md"
    )

    local script_files=(
        "common.sh"
        "create-user.sh"
        "copy-ssh-key.sh"
        "install-docker.sh"
        "clean-docker-logs.sh"
        "clean-docker-full.sh"
        "install-nodejs.sh"
        "install-nodejs-pm2.sh"
        "install-git.sh"
        "install-essentials.sh"
        "setup-firewall.sh"
        "setup-timezone.sh"
        "setup-swap.sh"
        "system-update.sh"
        "install-nginx.sh"
        "install-certbot.sh"
    )

    # Download main files
    for file in "${main_files[@]}"; do
        print_info "Downloading $file..."
        download "$RAW_URL/$file" "$INSTALL_DIR/$file"
    done

    # Download script files
    for file in "${script_files[@]}"; do
        print_info "Downloading scripts/$file..."
        download "$RAW_URL/scripts/$file" "$INSTALL_DIR/scripts/$file"
    done
}

# Set permissions
set_permissions() {
    print_stage "Setting permissions..."
    chmod +x "$INSTALL_DIR/setup.sh"
    chmod +x "$INSTALL_DIR/scripts/"*.sh
}

# Create symlink (optional)
create_symlink() {
    if [ "$EUID" -eq 0 ] || [ -w "/usr/local/bin" ]; then
        print_stage "Creating symlink..."
        ln -sf "$INSTALL_DIR/setup.sh" /usr/local/bin/devops-setup 2>/dev/null || true
    fi
}

# Main installation
main() {
    print_banner

    print_info "Install directory: $INSTALL_DIR"
    echo

    check_requirements

    if [ "$USE_GIT" = true ]; then
        install_with_git
    else
        install_with_download
    fi

    set_permissions
    create_symlink

    echo
    print_success "Installation complete!"
    echo
    print_info "To use the toolset:"
    echo -e "  ${CYAN}cd $INSTALL_DIR${NC}"
    echo -e "  ${CYAN}sudo ./setup.sh${NC}"
    echo
    print_info "Or run directly:"
    echo -e "  ${CYAN}sudo $INSTALL_DIR/setup.sh${NC}"
    echo
    if [ -L "/usr/local/bin/devops-setup" ]; then
        print_info "Global command available:"
        echo -e "  ${CYAN}sudo devops-setup${NC}"
        echo
    fi
    print_info "Show available tasks:"
    echo -e "  ${CYAN}$INSTALL_DIR/setup.sh --list${NC}"
    echo
}

# Run
main

