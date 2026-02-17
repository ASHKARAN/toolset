#!/bin/bash
# Common functions and utilities for all scripts

# Colors for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${BLUE}============================================${NC}"
}

print_success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

print_error() {
    echo -e "${RED}[✗] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

print_info() {
    echo -e "${BLUE}[i] $1${NC}"
}

print_stage() {
    echo -e "${YELLOW}>>> STAGE: $1${NC}"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root"
        exit 1
    fi
}

# Auto-yes for apt commands
export DEBIAN_FRONTEND=noninteractive
export APT_OPTS="-y -qq"

# Safe apt update
apt_update() {
    print_info "Updating package lists..."
    apt-get update $APT_OPTS > /dev/null 2>&1
}

# Safe apt install
apt_install() {
    print_info "Installing: $*"
    apt-get install $APT_OPTS "$@" > /dev/null 2>&1
}

# Safe apt upgrade
apt_upgrade() {
    print_info "Upgrading packages..."
    apt-get upgrade $APT_OPTS > /dev/null 2>&1
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Confirm action (defaults to yes)
confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-y}"

    if [ "$AUTO_YES" = "true" ]; then
        return 0
    fi

    read -p "$prompt [Y/n]: " response
    response=${response:-$default}
    [[ "$response" =~ ^[Yy] ]]
}

# Export AUTO_YES for non-interactive mode
export AUTO_YES="true"

