#!/usr/bin/env bash
set -e

# ============================================================
# DevOps Toolset Installer (Production-Grade)
# ============================================================

SCRIPT_MODE="${SCRIPT_MODE:-install}"

REPO_URL="https://github.com/ASHKARAN/toolset.git"
INSTALL_DIR="/usr/local/lib/devops-toolset"
BIN_DIR="/usr/local/bin"
VERSION_FILE="$INSTALL_DIR/.version"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success(){ echo -e "${GREEN}[✓] $1${NC}"; }
print_error(){ echo -e "${RED}[✗] $1${NC}"; }
print_info(){ echo -e "${BLUE}[i] $1${NC}"; }
print_warn(){ echo -e "${YELLOW}[!] $1${NC}"; }

require_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root (sudo)"
        exit 1
    fi
}

check_requirements() {
    if ! command -v git &>/dev/null; then
        print_error "git is required"
        exit 1
    fi
}

create_wrapper() {
    local name="$1"

    cat > "$BIN_DIR/$name" <<EOF
#!/usr/bin/env bash
exec $INSTALL_DIR/setup.sh "\$@"
EOF

    chmod +x "$BIN_DIR/$name"
    print_success "Created command: $name"
}

install_toolset() {
    require_root
    check_requirements

    print_info "Installing DevOps Toolset..."

    tmpdir=$(mktemp -d)

    git clone --depth=1 "$REPO_URL" "$tmpdir"

    rm -rf "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"

    cp -r "$tmpdir/"* "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/setup.sh"
    chmod +x "$INSTALL_DIR/install.sh"
    chmod +x "$INSTALL_DIR/scripts/"*.sh

    rm -rf "$tmpdir"

    create_wrapper devops
    create_wrapper toolset
    create_wrapper devops-setup

    date > "$VERSION_FILE"

    print_success "Installation complete."
    print_info "Run: sudo devops"
}

update_toolset() {
    require_root

    if [ ! -d "$INSTALL_DIR/.git" ]; then
        print_warn "No git repository found. Reinstalling..."
        install_toolset
        return
    fi

    print_info "Updating DevOps Toolset..."

    cd "$INSTALL_DIR"
    git fetch origin
    git reset --hard origin/main

    chmod +x setup.sh
    chmod +x install.sh
    chmod +x scripts/*.sh

    date > "$VERSION_FILE"

    print_success "Update complete."
}

uninstall_toolset() {
    require_root

    print_info "Uninstalling DevOps Toolset..."

    rm -rf "$INSTALL_DIR"
    rm -f "$BIN_DIR/devops"
    rm -f "$BIN_DIR/toolset"
    rm -f "$BIN_DIR/devops-setup"

    print_success "Uninstalled successfully."
}

case "$SCRIPT_MODE" in
    install)
        install_toolset
        ;;
    update)
        update_toolset
        ;;
    uninstall)
        uninstall_toolset
        ;;
    *)
        print_error "Unknown mode: $SCRIPT_MODE"
        exit 1
        ;;
esac