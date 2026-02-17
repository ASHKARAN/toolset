#!/bin/bash
#===============================================================================
#
#   DevOps Toolset - Server Setup Helper
#   A collection of scripts for initial server setup and configuration
#
#   Usage: ./setup.sh [options] [task_numbers...]
#
#   Examples:
#     ./setup.sh                    # Interactive menu
#     ./setup.sh 1 3 8              # Run tasks 1, 3, and 8
#     ./setup.sh --all              # Run all tasks
#     ./setup.sh --help             # Show help
#
#===============================================================================

set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

# Source common functions
source "$SCRIPTS_DIR/common.sh"

# Version
VERSION="1.0.0"

# Task definitions
declare -A TASKS
declare -A TASK_NAMES
declare -A TASK_DESCRIPTIONS

# Define all available tasks
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
TASK_DESCRIPTIONS[6]="Install Node.js using NVM (Node Version Manager)"

TASKS[7]="install-nodejs-pm2.sh"
TASK_NAMES[7]="Install Node.js + PM2"
TASK_DESCRIPTIONS[7]="Install Node.js (NVM) with PM2 process manager"

TASKS[8]="install-git.sh"
TASK_NAMES[8]="Install Git"
TASK_DESCRIPTIONS[8]="Install Git version control"

TASKS[9]="install-essentials.sh"
TASK_NAMES[9]="Install Essentials"
TASK_DESCRIPTIONS[9]="Install essential server packages (htop, curl, vim, etc.)"

TASKS[10]="setup-firewall.sh"
TASK_NAMES[10]="Setup Firewall"
TASK_DESCRIPTIONS[10]="Configure UFW firewall with basic rules"

TASKS[11]="setup-timezone.sh"
TASK_NAMES[11]="Setup Timezone"
TASK_DESCRIPTIONS[11]="Configure system timezone and NTP"

TASKS[12]="setup-swap.sh"
TASK_NAMES[12]="Setup Swap"
TASK_DESCRIPTIONS[12]="Create and configure swap space"

TASKS[13]="system-update.sh"
TASK_NAMES[13]="System Update"
TASK_DESCRIPTIONS[13]="Update and upgrade all system packages"

TASKS[14]="install-nginx.sh"
TASK_NAMES[14]="Install Nginx (Docker)"
TASK_DESCRIPTIONS[14]="Run Nginx in Docker with volume mappings"

TASKS[15]="install-certbot.sh"
TASK_NAMES[15]="Install Certbot"
TASK_DESCRIPTIONS[15]="Install Certbot for Let's Encrypt SSL certificates"

TOTAL_TASKS=15

# Show banner
show_banner() {
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
    echo -e "${BLUE}Server Setup Helper v${VERSION}${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

# Show help
show_help() {
    show_banner
    echo -e "${GREEN}USAGE:${NC}"
    echo "  devops [options] [task_numbers...]"
    echo "  toolset [options] [task_numbers...]"
    echo "  ./setup.sh [options] [task_numbers...]"
    echo
    echo -e "${GREEN}OPTIONS:${NC}"
    echo "  -h, --help        Show this help message"
    echo "  -v, --version     Show version"
    echo "  -l, --list        List all available tasks"
    echo "  -a, --all         Run all tasks (be careful!)"
    echo "  -u, --update      Update toolset from GitHub"
    echo "  -i, --interactive Run in interactive mode (default)"
    echo
    echo -e "${GREEN}EXAMPLES:${NC}"
    echo "  sudo devops                   # Interactive menu"
    echo "  sudo devops 1 3 8             # Run tasks 1, 3, and 8"
    echo "  sudo devops 13 9 8 3 10       # Common server setup"
    echo "  devops --list                 # Show all tasks"
    echo "  devops --update               # Update from GitHub"
    echo
    echo -e "${GREEN}GLOBAL COMMANDS:${NC}"
    echo "  After installation, these commands are available system-wide:"
    echo "    sudo devops     - Launch DevOps Toolset"
    echo "    sudo toolset    - Launch DevOps Toolset"
    echo
    echo -e "${GREEN}AVAILABLE TASKS:${NC}"
    list_tasks
}

# List all tasks
list_tasks() {
    for i in $(seq 1 $TOTAL_TASKS); do
        printf "  ${CYAN}%2d${NC}) %-25s - %s\n" "$i" "${TASK_NAMES[$i]}" "${TASK_DESCRIPTIONS[$i]}"
    done
}

# Show menu
show_menu() {
    show_banner
    echo -e "${GREEN}Available Tasks:${NC}"
    echo
    list_tasks
    echo
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "${GREEN}Enter task numbers separated by spaces (e.g., 1 3 8)${NC}"
    echo -e "${GREEN}Commands: 'q' quit | 'h' help | 'a' all tasks | 'u' update${NC}"
    echo
}

# Run a single task
run_task() {
    local task_num=$1
    local script="${TASKS[$task_num]}"
    local name="${TASK_NAMES[$task_num]}"

    if [ -z "$script" ]; then
        print_error "Invalid task number: $task_num"
        return 1
    fi

    local script_path="$SCRIPTS_DIR/$script"

    if [ ! -f "$script_path" ]; then
        print_error "Script not found: $script_path"
        return 1
    fi

    echo
    print_header "Task $task_num: $name"
    echo

    # Source and run the script
    source "$script_path"

    # Get the function name from script name (convert dashes to underscores)
    local func_name=$(basename "$script" .sh | tr '-' '_')

    # Run the function
    if declare -f "$func_name" > /dev/null; then
        "$func_name"
    fi

    echo
    print_success "Task $task_num completed: $name"
    echo
}

# Run multiple tasks
run_tasks() {
    local tasks=("$@")
    local total=${#tasks[@]}
    local current=0
    local failed=()

    echo
    print_info "Running $total task(s)..."
    echo

    for task_num in "${tasks[@]}"; do
        ((current++))
        echo -e "${BLUE}[$current/$total]${NC} Running task $task_num: ${TASK_NAMES[$task_num]}"

        if run_task "$task_num"; then
            :
        else
            failed+=("$task_num")
        fi
    done

    echo
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo

    if [ ${#failed[@]} -eq 0 ]; then
        print_success "All $total task(s) completed successfully!"
    else
        print_warning "${#failed[@]} task(s) failed: ${failed[*]}"
    fi
}

# Interactive mode
interactive_mode() {
    while true; do
        show_menu
        read -p "Your selection: " input

        case "$input" in
            q|Q|quit|exit)
                print_info "Goodbye!"
                exit 0
                ;;
            h|H|help)
                show_help
                read -p "Press Enter to continue..."
                ;;
            u|U|update)
                self_update
                exit 0
                ;;
            a|A|all)
                print_warning "This will run ALL tasks. Are you sure?"
                read -p "Type 'yes' to confirm: " confirm
                if [ "$confirm" = "yes" ]; then
                    run_tasks $(seq 1 $TOTAL_TASKS)
                fi
                read -p "Press Enter to continue..."
                ;;
            *)
                # Parse space-separated numbers
                local tasks=()
                for num in $input; do
                    if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le $TOTAL_TASKS ]; then
                        tasks+=("$num")
                    else
                        print_error "Invalid task number: $num"
                    fi
                done

                if [ ${#tasks[@]} -gt 0 ]; then
                    run_tasks "${tasks[@]}"
                    read -p "Press Enter to continue..."
                fi
                ;;
        esac
    done
}

# Self-update from GitHub
self_update() {
    print_info "Updating DevOps Toolset from GitHub..."
    echo

    local INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/ASHKARAN/toolset/main/install.sh"

    # Download and run installer in update mode
    if command -v curl &> /dev/null; then
        curl -fsSL "$INSTALL_SCRIPT_URL" | SCRIPT_MODE=update INSTALL_DIR="$SCRIPT_DIR" bash
    elif command -v wget &> /dev/null; then
        wget -qO- "$INSTALL_SCRIPT_URL" | SCRIPT_MODE=update INSTALL_DIR="$SCRIPT_DIR" bash
    else
        print_error "Neither curl nor wget found. Cannot update."
        exit 1
    fi
}

# Check root at start
check_root_required() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║  This script requires root privileges to run setup tasks.     ║${NC}"
        echo -e "${RED}║  Please run with: sudo ./setup.sh                             ║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
        exit 1
    fi
}

# Main entry point
main() {
    # Parse arguments
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "DevOps Toolset v$VERSION"
            exit 0
            ;;
        -l|--list)
            show_banner
            echo -e "${GREEN}Available Tasks:${NC}"
            echo
            list_tasks
            exit 0
            ;;
        -u|--update)
            show_banner
            self_update
            exit 0
            ;;
        -a|--all)
            check_root_required
            show_banner
            run_tasks $(seq 1 $TOTAL_TASKS)
            exit 0
            ;;
        -i|--interactive|"")
            check_root_required
            interactive_mode
            ;;
        *)
            # Check if arguments are task numbers
            local tasks=()
            for arg in "$@"; do
                if [[ "$arg" =~ ^[0-9]+$ ]] && [ "$arg" -ge 1 ] && [ "$arg" -le $TOTAL_TASKS ]; then
                    tasks+=("$arg")
                else
                    print_error "Invalid argument: $arg"
                    echo "Use --help for usage information"
                    exit 1
                fi
            done

            if [ ${#tasks[@]} -gt 0 ]; then
                check_root_required
                show_banner
                run_tasks "${tasks[@]}"
            fi
            ;;
    esac
}

# Run main
main "$@"

