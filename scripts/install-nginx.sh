#!/bin/bash
# Run Nginx in Docker with volume mappings for config, logs, and web content

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Default paths
NGINX_BASE_DIR="/opt/nginx"
NGINX_CONF_DIR="$NGINX_BASE_DIR/conf"
NGINX_LOG_DIR="$NGINX_BASE_DIR/logs"
NGINX_HTML_DIR="$NGINX_BASE_DIR/html"
NGINX_CERTS_DIR="$NGINX_BASE_DIR/certs"
NGINX_CONTAINER_NAME="nginx-server"

install_nginx() {
    check_root
    print_header "Install Nginx (Docker)"

    # Check if Docker is installed
    if ! command_exists docker; then
        print_warning "Docker is not installed!"
        print_info "Attempting to install Docker first..."

        # Source and run docker installation
        source "$SCRIPT_DIR/install-docker.sh"
        install_docker

        # Verify Docker is now available
        if ! command_exists docker; then
            print_error "Docker installation failed. Cannot proceed with Nginx."
            return 1
        fi
    fi

    # Check if Docker daemon is running
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker daemon is not running. Please start Docker first."
        return 1
    fi

    print_stage "Creating Nginx directories"
    mkdir -p "$NGINX_CONF_DIR/conf.d"
    mkdir -p "$NGINX_LOG_DIR"
    mkdir -p "$NGINX_HTML_DIR"
    mkdir -p "$NGINX_CERTS_DIR"

    # Create default nginx.conf if not exists
    if [ ! -f "$NGINX_CONF_DIR/nginx.conf" ]; then
        print_stage "Creating default nginx.conf"
        cat > "$NGINX_CONF_DIR/nginx.conf" << 'EOF'
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    tcp_nopush      on;
    tcp_nodelay     on;
    keepalive_timeout  65;
    types_hash_max_size 2048;

    # Gzip compression
    gzip  on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml application/json application/javascript application/rss+xml application/atom+xml image/svg+xml;

    # Include additional configs
    include /etc/nginx/conf.d/*.conf;
}
EOF
    fi

    # Create default server config if not exists
    if [ ! -f "$NGINX_CONF_DIR/conf.d/default.conf" ]; then
        print_stage "Creating default server configuration"
        cat > "$NGINX_CONF_DIR/conf.d/default.conf" << 'EOF'
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    root   /usr/share/nginx/html;
    index  index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
    fi

    # Create default index.html if not exists
    if [ ! -f "$NGINX_HTML_DIR/index.html" ]; then
        print_stage "Creating default index.html"
        cat > "$NGINX_HTML_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to Nginx (Docker)</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 40px auto; max-width: 650px; line-height: 1.6; padding: 0 10px; color: #333; }
        h1 { color: #009639; }
        code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; }
    </style>
</head>
<body>
    <h1>Welcome to Nginx!</h1>
    <p>Nginx is running successfully inside Docker.</p>
    <h2>Quick Info</h2>
    <ul>
        <li>Config: <code>/opt/nginx/conf/</code></li>
        <li>Logs: <code>/opt/nginx/logs/</code></li>
        <li>Web Root: <code>/opt/nginx/html/</code></li>
        <li>SSL Certs: <code>/opt/nginx/certs/</code></li>
    </ul>
    <p>Edit files in these directories and reload Nginx:</p>
    <code>docker exec nginx-server nginx -s reload</code>
</body>
</html>
EOF
    fi

    # Stop and remove existing container if exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${NGINX_CONTAINER_NAME}$"; then
        print_stage "Stopping existing Nginx container"
        docker stop "$NGINX_CONTAINER_NAME" > /dev/null 2>&1
        docker rm "$NGINX_CONTAINER_NAME" > /dev/null 2>&1
    fi

    print_stage "Pulling latest Nginx image"
    docker pull nginx:latest > /dev/null 2>&1

    print_stage "Starting Nginx container"
    docker run -d \
        --name "$NGINX_CONTAINER_NAME" \
        --restart unless-stopped \
        -p 80:80 \
        -p 443:443 \
        -v "$NGINX_CONF_DIR/nginx.conf:/etc/nginx/nginx.conf:ro" \
        -v "$NGINX_CONF_DIR/conf.d:/etc/nginx/conf.d:ro" \
        -v "$NGINX_HTML_DIR:/usr/share/nginx/html:ro" \
        -v "$NGINX_LOG_DIR:/var/log/nginx" \
        -v "$NGINX_CERTS_DIR:/etc/nginx/certs:ro" \
        nginx:latest > /dev/null 2>&1

    # Wait for container to start
    sleep 2

    # Check if container is running
    if docker ps --format '{{.Names}}' | grep -q "^${NGINX_CONTAINER_NAME}$"; then
        print_success "Nginx container started successfully"
    else
        print_error "Failed to start Nginx container"
        print_info "Check logs with: docker logs $NGINX_CONTAINER_NAME"
        return 1
    fi

    # Get container info
    local NGINX_VERSION=$(docker exec "$NGINX_CONTAINER_NAME" nginx -v 2>&1 | cut -d'/' -f2)

    print_info "Nginx version: $NGINX_VERSION"
    print_info "Container name: $NGINX_CONTAINER_NAME"

    echo
    print_info "Directory Structure:"
    echo "  $NGINX_CONF_DIR/nginx.conf    - Main configuration"
    echo "  $NGINX_CONF_DIR/conf.d/       - Server configurations"
    echo "  $NGINX_HTML_DIR/              - Web root directory"
    echo "  $NGINX_LOG_DIR/               - Log files"
    echo "  $NGINX_CERTS_DIR/             - SSL certificates"

    echo
    print_info "Useful Commands:"
    echo "  docker logs $NGINX_CONTAINER_NAME              - View logs"
    echo "  docker exec $NGINX_CONTAINER_NAME nginx -t     - Test config"
    echo "  docker exec $NGINX_CONTAINER_NAME nginx -s reload - Reload config"
    echo "  docker restart $NGINX_CONTAINER_NAME           - Restart Nginx"
    echo "  docker stop $NGINX_CONTAINER_NAME              - Stop Nginx"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_nginx "$@"
fi

