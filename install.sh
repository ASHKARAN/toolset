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
#   Update existing installation:
#     devops --update
#     toolset --update
#
#===============================================================================

set -e

# Script mode (install or update)
SCRIPT_MODE="${SCRIPT_MODE:-install}"

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
    if [ "$SCRIPT_MODE" = "update" ]; then
        print_stage "Updating from GitHub..."
    else
        print_stage "Cloning repository..."
    fi

    if [ -d "$INSTALL_DIR/.git" ]; then
        print_info "Git repository found, pulling latest changes..."
        cd "$INSTALL_DIR"
        git fetch --all --quiet
        git reset --quiet --hard origin/main
        print_success "Updated to latest version"
    elif [ -d "$INSTALL_DIR" ]; then
        print_info "Directory exists but not a git repo, converting..."
        rm -rf "$INSTALL_DIR"
        git clone --quiet "$REPO_URL" "$INSTALL_DIR"
    else
        git clone --quiet "$REPO_URL" "$INSTALL_DIR"
    fi
}

# Install by downloading individual files
install_with_download() {
    if [ "$SCRIPT_MODE" = "update" ]; then
        print_stage "Updating toolset files from GitHub..."
        # Remove existing scripts to ensure clean update
        rm -rf "$INSTALL_DIR/scripts" 2>/dev/null || true
    else
        print_stage "Downloading toolset files..."
    fi

    # Create directories
    mkdir -p "$INSTALL_DIR/scripts"

    # List of files to download
    local main_files=(
        "setup.sh"
        "install.sh"
        "README.md"
        "LICENSE"
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

# Create symlinks for global commands
create_symlinks() {
    print_stage "Creating symlinks..."

    local symlink_dir="/usr/local/bin"
    local commands=("devops" "toolset" "devops-setup")

    # Check if we have write access
    if [ "$EUID" -eq 0 ] || [ -w "$symlink_dir" ]; then
        for cmd in "${commands[@]}"; do
            ln -sf "$INSTALL_DIR/setup.sh" "$symlink_dir/$cmd" 2>/dev/null && \
                print_success "Created symlink: $cmd" || \
                print_error "Failed to create symlink: $cmd"
        done
    else
        # Try with sudo if available
        if command -v sudo &> /dev/null; then
            print_info "Requesting sudo to create symlinks..."
            for cmd in "${commands[@]}"; do
                sudo ln -sf "$INSTALL_DIR/setup.sh" "$symlink_dir/$cmd" 2>/dev/null && \
                    print_success "Created symlink: $cmd" || \
                    print_error "Failed to create symlink: $cmd"
            done
        else
            print_info "Cannot create symlinks without root access"
            print_info "Run as root or manually create symlinks:"
            for cmd in "${commands[@]}"; do
                echo -e "  ${CYAN}sudo ln -sf $INSTALL_DIR/setup.sh $symlink_dir/$cmd${NC}"
            done
        fi
    fi
}

# Main installation
main() {
    print_banner

    if [ "$SCRIPT_MODE" = "update" ]; then
        print_info "Update mode - Refetching from GitHub"
    else
        print_info "Install directory: $INSTALL_DIR"
    fi
    echo

    check_requirements

    if [ "$USE_GIT" = true ]; then
        install_with_git
    else
        install_with_download
    fi

    set_permissions
    create_symlinks

    echo
    if [ "$SCRIPT_MODE" = "update" ]; then
        print_success "Update complete!"
    else
        print_success "Installation complete!"
    fi
    echo
    print_info "To use the toolset:"
    echo -e "  ${CYAN}cd $INSTALL_DIR${NC}"
    echo -e "  ${CYAN}sudo ./setup.sh${NC}"
    echo
    print_info "Or run directly:"
    echo -e "  ${CYAN}sudo $INSTALL_DIR/setup.sh${NC}"
    echo
    if [ -L "/usr/local/bin/devops" ]; then
        print_info "Global commands available:"
        echo -e "  ${CYAN}sudo devops${NC}"
        echo -e "  ${CYAN}sudo toolset${NC}"
        echo -e "  ${CYAN}sudo devops-setup${NC}"
        echo
        print_info "Update toolset:"
        echo -e "  ${CYAN}devops --update${NC}"
        echo -e "  ${CYAN}toolset --update${NC}"
        echo
    fi
    print_info "Show available tasks:"
    echo -e "  ${CYAN}$INSTALL_DIR/setup.sh --list${NC}"
    echo
}

# Run
main

