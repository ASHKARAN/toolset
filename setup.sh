#!/usr/bin/env bash
set -e

# ============================================================
# DevOps Toolset CLI
# ============================================================

INSTALL_DIR="/usr/local/lib/devops-toolset"
SCRIPTS_DIR="$INSTALL_DIR/scripts"
VERSION="2.0.0"

source "$SCRIPTS_DIR/common.sh"

declare -A TASKS
declare -A TASK_NAMES
declare -A TASK_DESCRIPTIONS

TASKS[1]="create-user.sh"
TASK_NAMES[1]="Create User"
TASK_DESCRIPTIONS[1]="Create a new user with sudo privileges and SSH setup"

TASKS[2]="copy-ssh-key.sh"
TASK_NAMES[2]="Copy SSH Key"
TASK_DESCRIPTIONS[2]="Add SSH public key to a user's authorized_keys"

TASKS[3]="install-docker.sh"
TASK_NAMES[3]="Install Docker"
TASK_DESCRIPTIONS[3]="Install Docker Engine and Docker Compose"

TASKS[4]="clean-docker-logs.sh"
TASK_NAMES[4]="Clean Docker Logs"
TASK_DESCRIPTIONS[4]="Truncate all Docker container log files"

TASKS[5]="clean-docker-full.sh"
TASK_NAMES[5]="Clean Docker Full"
TASK_DESCRIPTIONS[5]="Remove all Docker containers, images, volumes, and networks"

TASKS[6]="install-nodejs.sh"
TASK_NAMES[6]="Install Node.js (NVM)"
TASK_DESCRIPTIONS[6]="Install Node.js using NVM"

TASKS[7]="install-nodejs-pm2.sh"
TASK_NAMES[7]="Install Node.js + PM2"
TASK_DESCRIPTIONS[7]="Install Node.js with PM2"

TASKS[8]="install-git.sh"
TASK_NAMES[8]="Install Git"
TASK_DESCRIPTIONS[8]="Install Git"

TASKS[9]="install-essentials.sh"
TASK_NAMES[9]="Install Essentials"
TASK_DESCRIPTIONS[9]="Install essential packages"

TASKS[10]="setup-firewall.sh"
TASK_NAMES[10]="Setup Firewall"
TASK_DESCRIPTIONS[10]="Configure UFW firewall"

TASKS[11]="setup-timezone.sh"
TASK_NAMES[11]="Setup Timezone"
TASK_DESCRIPTIONS[11]="Configure timezone"

TASKS[12]="setup-swap.sh"
TASK_NAMES[12]="Setup Swap"
TASK_DESCRIPTIONS[12]="Create swap space"

TASKS[13]="system-update.sh"
TASK_NAMES[13]="System Update"
TASK_DESCRIPTIONS[13]="Update system packages"

TASKS[14]="install-nginx.sh"
TASK_NAMES[14]="Install Nginx (Docker)"
TASK_DESCRIPTIONS[14]="Run Nginx container"

TASKS[15]="install-certbot.sh"
TASK_NAMES[15]="Install Certbot"
TASK_DESCRIPTIONS[15]="Install SSL certbot"

TOTAL_TASKS=15

run_task() {
    local num=$1
    local script="${TASKS[$num]}"

    if [ -z "$script" ]; then
        print_error "Invalid task number"
        exit 1
    fi

    source "$SCRIPTS_DIR/$script"
    func=$(basename "$script" .sh | tr '-' '_')

    if declare -f "$func" >/dev/null; then
        "$func"
    else
        print_error "Function $func not found"
        exit 1
    fi
}

list_tasks() {
    for i in $(seq 1 $TOTAL_TASKS); do
        printf "%2d) %-25s - %s\n" \
        "$i" "${TASK_NAMES[$i]}" "${TASK_DESCRIPTIONS[$i]}"
    done
}

require_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "Run with sudo"
        exit 1
    fi
}

case "${1:-}" in
    -h|--help)
        echo "DevOps Toolset v$VERSION"
        echo "Usage: sudo devops [task_numbers]"
        list_tasks
        exit 0
        ;;
    -l|--list)
        list_tasks
        exit 0
        ;;
    -u|--update)
        SCRIPT_MODE=update bash "$INSTALL_DIR/install.sh"
        exit 0
        ;;
    --uninstall)
        SCRIPT_MODE=uninstall bash "$INSTALL_DIR/install.sh"
        exit 0
        ;;
    "")
        print_error "Specify task numbers or --help"
        exit 1
        ;;
    *)
        require_root
        for arg in "$@"; do
            run_task "$arg"
        done
        ;;
esac