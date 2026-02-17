#!/bin/bash
# Install Node.js using NVM (Node Version Manager)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_nodejs() {
    check_root
    print_header "Install Node.js (NVM)"

    # Node.js version (default: LTS)
    local NODE_VERSION="${1:---lts}"

    # Target user (default: SUDO_USER or root)
    local TARGET_USER="${SUDO_USER:-root}"
    local TARGET_HOME=$(eval echo "~$TARGET_USER")

    print_stage "Installing prerequisites"
    apt_update
    apt_install curl wget

    print_stage "Installing NVM for user: $TARGET_USER"

    # NVM version
    local NVM_VERSION="v0.40.1"
    local NVM_DIR="$TARGET_HOME/.nvm"

    # Install NVM as target user
    su - "$TARGET_USER" -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash" > /dev/null 2>&1

    # Add NVM to shell profile if not already there
    local PROFILE_FILE="$TARGET_HOME/.bashrc"
    if ! grep -q "NVM_DIR" "$PROFILE_FILE" 2>/dev/null; then
        cat >> "$PROFILE_FILE" << 'EOF'

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
        chown "$TARGET_USER:$TARGET_USER" "$PROFILE_FILE"
    fi

    print_stage "Installing Node.js $NODE_VERSION"

    # Install Node.js using NVM
    su - "$TARGET_USER" -c "export NVM_DIR=\"$NVM_DIR\" && . \"$NVM_DIR/nvm.sh\" && nvm install $NODE_VERSION && nvm alias default node"

    # Get installed versions
    local NODE_V=$(su - "$TARGET_USER" -c "export NVM_DIR=\"$NVM_DIR\" && . \"$NVM_DIR/nvm.sh\" && node -v" 2>/dev/null)
    local NPM_V=$(su - "$TARGET_USER" -c "export NVM_DIR=\"$NVM_DIR\" && . \"$NVM_DIR/nvm.sh\" && npm -v" 2>/dev/null)

    print_success "Node.js installed successfully"
    print_info "Node.js version: $NODE_V"
    print_info "npm version: $NPM_V"
    print_info "NVM directory: $NVM_DIR"
    print_info "Installed for user: $TARGET_USER"

    echo
    print_info "NVM Quick Reference:"
    echo "  nvm install <version>  - Install a Node.js version"
    echo "  nvm use <version>      - Switch to a version"
    echo "  nvm ls                 - List installed versions"
    echo "  nvm ls-remote          - List available versions"
    echo "  nvm alias default <v>  - Set default version"
    echo
    print_warning "Run 'source ~/.bashrc' or re-login to use Node.js"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_nodejs "$@"
fi
