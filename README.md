# DevOps Toolset - Server Setup Helper

A collection of bash scripts for automating initial server setup and configuration tasks on Ubuntu/Debian systems.

## One-Line Installation

```bash
# Using curl
curl -fsSL https://raw.githubusercontent.com/ASHKARAN/toolset/main/install.sh | bash

# Using wget
wget -qO- https://raw.githubusercontent.com/ASHKARAN/toolset/main/install.sh | bash

# Custom install directory
curl -fsSL https://raw.githubusercontent.com/ASHKARAN/toolset/main/install.sh | INSTALL_DIR=/opt/toolset bash
```

After installation, run:
```bash
sudo ~/toolset/setup.sh
```

## Features

- 🎯 **Interactive Menu**: Easy-to-use menu-driven interface
- 🔢 **Multi-task Selection**: Run multiple tasks at once (e.g., `1 3 8`)
- 🤖 **Auto-yes Mode**: No manual confirmations needed
- 📦 **Modular Design**: Each task is a separate script
- 🎨 **Colored Output**: Clear, readable status messages

## Quick Start

```bash
# Clone or download the toolset
cd /path/to/toolset

# Make scripts executable
chmod +x setup.sh
chmod +x scripts/*.sh

# Run the setup helper (requires root)
sudo ./setup.sh
```

## Usage

### Interactive Mode (default)
```bash
sudo ./setup.sh
```

### Run Specific Tasks
```bash
# Run tasks 1, 3, and 8
sudo ./setup.sh 1 3 8

# Run tasks 1 through 5
sudo ./setup.sh 1 2 3 4 5
```

### Other Commands
```bash
./setup.sh --help       # Show help
./setup.sh --list       # List all tasks
./setup.sh --version    # Show version
sudo ./setup.sh --all   # Run all tasks (careful!)
```

## Available Tasks

| # | Task | Description |
|---|------|-------------|
| 1 | Create User | Create a new user with sudo privileges and SSH setup |
| 2 | Copy SSH Key | Add SSH public key to a user's authorized_keys |
| 3 | Install Docker | Install Docker Engine and Docker Compose |
| 4 | Clean Docker Logs | Truncate all Docker container log files |
| 5 | Clean Docker Full | Remove all Docker containers, images, volumes, networks |
| 6 | Install Node.js (NVM) | Install Node.js using NVM (Node Version Manager) |
| 7 | Install Node.js + PM2 | Install Node.js (NVM) with PM2 process manager |
| 8 | Install Git | Install Git version control |
| 9 | Install Essentials | Install essential packages (htop, curl, vim, etc.) |
| 10 | Setup Firewall | Configure UFW firewall with basic rules |
| 11 | Setup Timezone | Configure system timezone and NTP |
| 12 | Setup Swap | Create and configure swap space |
| 13 | System Update | Update and upgrade all system packages |
| 14 | Install Nginx (Docker) | Run Nginx in Docker with volume mappings |
| 15 | Install Certbot | Install Certbot for Let's Encrypt SSL |

## Directory Structure

```
toolset/
├── setup.sh                    # Main helper script
├── README.md                   # This file
└── scripts/
    ├── common.sh               # Common functions and utilities
    ├── create-user.sh          # Create user task
    ├── copy-ssh-key.sh         # Copy SSH key task
    ├── install-docker.sh       # Install Docker task
    ├── clean-docker-logs.sh    # Clean Docker logs task
    ├── clean-docker-full.sh    # Full Docker cleanup task
    ├── install-nodejs.sh       # Install Node.js (NVM) task
    ├── install-nodejs-pm2.sh   # Install Node.js + PM2 task
    ├── install-git.sh          # Install Git task
    ├── install-essentials.sh   # Install essentials task
    ├── setup-firewall.sh       # Setup firewall task
    ├── setup-timezone.sh       # Setup timezone task
    ├── setup-swap.sh           # Setup swap task
    ├── system-update.sh        # System update task
    ├── install-nginx.sh        # Install Nginx (Docker) task
    └── install-certbot.sh      # Install Certbot task
```

## Running Individual Scripts

Each script can also be run independently:

```bash
# Run a specific script directly
sudo ./scripts/install-docker.sh

# Or source and call the function
source ./scripts/common.sh
source ./scripts/install-nodejs.sh
install_nodejs --lts  # Install Node.js LTS
```

## Node.js with NVM

Node.js is installed using NVM (Node Version Manager), allowing you to:
- Install multiple Node.js versions
- Switch between versions easily
- Install per-user (not system-wide)

```bash
# After installation, use NVM commands:
nvm install 20          # Install Node.js 20
nvm install --lts       # Install latest LTS
nvm use 20              # Switch to version 20
nvm alias default 20    # Set default version
```

## Nginx (Docker)

Nginx runs inside a Docker container with the following volume mappings:

| Host Path | Container Path | Purpose |
|-----------|----------------|---------|
| `/opt/nginx/conf/nginx.conf` | `/etc/nginx/nginx.conf` | Main config |
| `/opt/nginx/conf/conf.d/` | `/etc/nginx/conf.d/` | Server configs |
| `/opt/nginx/html/` | `/usr/share/nginx/html/` | Web root |
| `/opt/nginx/logs/` | `/var/log/nginx/` | Log files |
| `/opt/nginx/certs/` | `/etc/nginx/certs/` | SSL certificates |

### Nginx Commands
```bash
# View logs
docker logs nginx-server

# Test configuration
docker exec nginx-server nginx -t

# Reload configuration
docker exec nginx-server nginx -s reload

# Restart container
docker restart nginx-server
```

## Recommended Initial Setup

For a typical new server, run these tasks in order:

```bash
# Essential setup
sudo ./setup.sh 13 9 8 3 10 12 11

# This will:
# 13 - Update system
# 9  - Install essential packages
# 8  - Install Git
# 3  - Install Docker
# 10 - Setup firewall
# 12 - Setup swap
# 11 - Setup timezone
```

For a web server with Node.js:

```bash
sudo ./setup.sh 13 9 8 3 6 14 15 10 12

# Includes Docker, Node.js (NVM), Nginx (Docker), and Certbot
```

## Requirements

- Ubuntu 20.04+ or Debian 10+
- Root access (sudo)
- Internet connection

## License

MIT License - Use freely for your projects.

## Contributing

Feel free to add new tasks or improve existing ones!
