#!/bin/bash
# Full Docker cleanup - containers, images, volumes, networks

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

clean_docker_full() {
    check_root
    print_header "Full Docker Cleanup"

    if ! command_exists docker; then
        print_error "Docker is not installed"
        return 1
    fi

    print_warning "This will remove ALL Docker data!"
    print_warning "- All containers (running and stopped)"
    print_warning "- All images"
    print_warning "- All volumes"
    print_warning "- All custom networks"
    echo

    print_stage "Stopping all running containers"
    local containers=$(docker ps -aq)
    if [ -n "$containers" ]; then
        docker stop $containers 2>/dev/null
        print_info "Stopped containers"
    else
        print_info "No containers running"
    fi

    print_stage "Removing all containers"
    if [ -n "$containers" ]; then
        docker rm -f $containers 2>/dev/null
        print_info "Removed containers"
    fi

    print_stage "Removing all images"
    local images=$(docker images -q)
    if [ -n "$images" ]; then
        docker rmi -f $images 2>/dev/null
        print_info "Removed images"
    else
        print_info "No images to remove"
    fi

    print_stage "Removing all volumes"
    local volumes=$(docker volume ls -q)
    if [ -n "$volumes" ]; then
        docker volume rm $volumes 2>/dev/null
        print_info "Removed volumes"
    else
        print_info "No volumes to remove"
    fi

    print_stage "Removing custom networks"
    local networks=$(docker network ls -q --filter type=custom)
    if [ -n "$networks" ]; then
        docker network rm $networks 2>/dev/null
        print_info "Removed networks"
    else
        print_info "No custom networks to remove"
    fi

    print_stage "Running system prune"
    docker system prune -a --volumes -f

    print_success "Docker cleanup completed"
    print_info "Docker disk usage:"
    docker system df
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    clean_docker_full "$@"
fi

