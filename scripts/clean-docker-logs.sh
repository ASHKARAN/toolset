#!/bin/bash
# Clean Docker logs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

clean_docker_logs() {
    check_root
    print_header "Clean Docker Logs"

    if ! command_exists docker; then
        print_error "Docker is not installed"
        return 1
    fi

    print_stage "Finding Docker log files"
    local log_dir="/var/lib/docker/containers"

    if [ ! -d "$log_dir" ]; then
        print_warning "Docker containers directory not found"
        return 1
    fi

    # Get current size
    local before_size=$(du -sh "$log_dir" 2>/dev/null | cut -f1)
    print_info "Current logs size: $before_size"

    print_stage "Truncating container log files"
    find "$log_dir" -name "*-json.log" -exec truncate -s 0 {} \;

    # Get new size
    local after_size=$(du -sh "$log_dir" 2>/dev/null | cut -f1)
    print_success "Logs cleaned successfully"
    print_info "Size after cleanup: $after_size"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    clean_docker_logs "$@"
fi

