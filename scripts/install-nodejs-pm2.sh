#!/bin/bash
# Install Node.js (NVM) with PM2 process manager

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_nodejs_pm2() {
    check_root
    print_header "Install Node.js (NVM) with PM2"

    # Target user
    local TARGET_USER="${SUDO_USER:-root}"
    local TARGET_HOME=$(eval echo "~$TARGET_USER")
    local NVM_DIR="$TARGET_HOME/.nvm"

    # First install Node.js using NVM
    source "$SCRIPT_DIR/install-nodejs.sh"
    install_nodejs "${1:---lts}"

    print_stage "Installing PM2 globally"
    su - "$TARGET_USER" -c "export NVM_DIR=\"$NVM_DIR\" && . \"$NVM_DIR/nvm.sh\" && npm install -g pm2" > /dev/null 2>&1

    print_stage "Setting up PM2 startup script"
    # Get the startup command
    local STARTUP_CMD=$(su - "$TARGET_USER" -c "export NVM_DIR=\"$NVM_DIR\" && . \"$NVM_DIR/nvm.sh\" && pm2 startup systemd -u $TARGET_USER --hp $TARGET_HOME 2>/dev/null | grep 'sudo'")

    # Execute the startup command if found
    if [ -n "$STARTUP_CMD" ]; then
        eval "$STARTUP_CMD" > /dev/null 2>&1
    fi

    # Get PM2 version
    local PM2_V=$(su - "$TARGET_USER" -c "export NVM_DIR=\"$NVM_DIR\" && . \"$NVM_DIR/nvm.sh\" && pm2 -v" 2>/dev/null)

    print_success "PM2 installed successfully"
    print_info "PM2 version: $PM2_V"

    echo
    print_info "PM2 Quick Reference:"
    echo "  pm2 start app.js       - Start an application"
    echo "  pm2 list               - List all running processes"
    echo "  pm2 stop <id|name>     - Stop a process"
    echo "  pm2 restart <id|name>  - Restart a process"
    echo "  pm2 logs               - View logs"
    echo "  pm2 save               - Save process list"
    echo "  pm2 resurrect          - Restore saved processes"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_nodejs_pm2 "$@"
fi

