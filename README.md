# DevOps Toolset

A comprehensive collection of bash scripts for automating server setup and configuration tasks on Ubuntu/Debian systems.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Available Tasks](#available-tasks)
- [Task Details](#task-details)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Interactive Menu** — Easy-to-use menu-driven interface for task selection
- **One-Line Install** — Get started in seconds with a single command
- **Global Commands** — Run from anywhere using `devops` or `toolset` commands
- **Self-Update** — Keep your toolset current with `--update`
- **Multi-task Execution** — Run multiple tasks in sequence (e.g., `1 3 8`)
- **Modular Design** — Each task is a separate, maintainable script
- **Safe Defaults** — Confirmation prompts for destructive operations

## Installation

### Quick Install (Recommended)

Using curl:
```bash
curl -fsSL https://raw.githubusercontent.com/ASHKARAN/toolset/main/install.sh | bash
```

Using wget:
```bash
wget -qO- https://raw.githubusercontent.com/ASHKARAN/toolset/main/install.sh | bash
```

### Custom Install Directory

```bash
curl -fsSL https://raw.githubusercontent.com/ASHKARAN/toolset/main/install.sh | INSTALL_DIR=/opt/toolset bash
```

### Manual Installation

```bash
git clone https://github.com/ASHKARAN/toolset.git ~/toolset
cd ~/toolset
chmod +x setup.sh install.sh scripts/*.sh
```

## Usage

### Global Commands

After installation, the following commands are available system-wide:

| Command | Description |
|---------|-------------|
| `sudo devops` | Launch the DevOps Toolset |
| `sudo toolset` | Launch the DevOps Toolset |
| `devops --help` | Show help and available options |
| `devops --list` | List all available tasks |
| `devops --update` | Update toolset from GitHub |

### Interactive Mode

```bash
sudo devops
```

This opens an interactive menu where you can select tasks by number.

### Run Specific Tasks

```bash
# Run a single task
sudo devops 3

# Run multiple tasks
sudo devops 1 3 8

# Run a sequence of tasks
sudo devops 13 9 8 3 10
```

### Command Line Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-v, --version` | Show version |
| `-l, --list` | List all available tasks |
| `-a, --all` | Run all tasks (use with caution) |
| `-u, --update` | Update from GitHub |
| `-i, --interactive` | Run in interactive mode (default) |

### Updating

Keep your toolset up-to-date:

```bash
devops --update
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
| 7 | Install Node.js + PM2 | Install Node.js with PM2 process manager |
| 8 | Install Git | Install Git version control |
| 9 | Install Essentials | Install essential packages (htop, curl, vim, etc.) |
| 10 | Setup Firewall | Configure UFW firewall with basic rules |
| 11 | Setup Timezone | Configure system timezone and NTP |
| 12 | Setup Swap | Create and configure swap space |
| 13 | System Update | Update and upgrade all system packages |
| 14 | Install Nginx (Docker) | Run Nginx in Docker with volume mappings |
| 15 | Install Certbot | Install Certbot for Let's Encrypt SSL certificates |

## Task Details

### Docker

Installs Docker Engine and Docker Compose with proper configuration.

```bash
sudo devops 3    # Install Docker
sudo devops 4    # Clean Docker logs
sudo devops 5    # Full Docker cleanup (removes everything)
```

### Node.js with NVM

Node.js is installed using NVM (Node Version Manager) for flexibility:

```bash
sudo devops 6    # Install Node.js (NVM only)
sudo devops 7    # Install Node.js + PM2
```

After installation, use NVM commands:

```bash
nvm install 20          # Install Node.js 20
nvm install --lts       # Install latest LTS
nvm use 20              # Switch to version 20
nvm alias default 20    # Set default version
```

### Nginx (Docker)

Nginx runs inside a Docker container with the following volume mappings:

| Host Path | Container Path | Purpose |
|-----------|----------------|---------|
| `/opt/nginx/conf/nginx.conf` | `/etc/nginx/nginx.conf` | Main config |
| `/opt/nginx/conf/conf.d/` | `/etc/nginx/conf.d/` | Server configs |
| `/opt/nginx/html/` | `/usr/share/nginx/html/` | Web root |
| `/opt/nginx/logs/` | `/var/log/nginx/` | Log files |
| `/opt/nginx/certs/` | `/etc/nginx/certs/` | SSL certificates |

Common Nginx commands:

```bash
docker logs nginx-server              # View logs
docker exec nginx-server nginx -t     # Test config
docker exec nginx-server nginx -s reload  # Reload config
docker restart nginx-server           # Restart container
```

### Firewall (UFW)

Configures UFW firewall with secure defaults:

- Allow SSH (port 22)
- Allow HTTP (port 80)
- Allow HTTPS (port 443)
- Deny all other incoming traffic

## Recommended Setup Sequences

### New Server (Basic)

```bash
sudo devops 13 9 8 10 12 11
```

This will:
- Update system packages (13)
- Install essential tools (9)
- Install Git (8)
- Setup firewall (10)
- Configure swap space (12)
- Set timezone (11)

### Web Server with Docker

```bash
sudo devops 13 9 8 3 14 15 10 12 11
```

Includes Docker, Nginx, and Certbot for SSL.

### Node.js Application Server

```bash
sudo devops 13 9 8 3 7 10 12 11
```

Includes Node.js with PM2 for process management.

### Full Stack Setup

```bash
sudo devops 13 9 8 3 7 14 15 10 12 11 1
```

Complete setup including user creation for deployments.

## Project Structure

```
toolset/
├── install.sh              # One-line installer script
├── setup.sh                # Main CLI and interactive menu
├── README.md               # Documentation
├── LICENSE                 # MIT License
└── scripts/
    ├── common.sh           # Shared functions and utilities
    ├── create-user.sh      # User creation with sudo & SSH
    ├── copy-ssh-key.sh     # SSH key management
    ├── install-docker.sh   # Docker & Docker Compose setup
    ├── clean-docker-logs.sh    # Docker log cleanup
    ├── clean-docker-full.sh    # Complete Docker cleanup
    ├── install-nodejs.sh   # Node.js via NVM
    ├── install-nodejs-pm2.sh   # Node.js + PM2 setup
    ├── install-git.sh      # Git installation
    ├── install-essentials.sh   # Essential packages
    ├── setup-firewall.sh   # UFW firewall configuration
    ├── setup-timezone.sh   # Timezone & NTP setup
    ├── setup-swap.sh       # Swap space configuration
    ├── system-update.sh    # System updates
    ├── install-nginx.sh    # Nginx in Docker
    └── install-certbot.sh  # Certbot for SSL
```

## Running Individual Scripts

Each script can be run independently:

```bash
# Run a specific script directly
sudo ~/toolset/scripts/install-docker.sh

# Or source and call the function
source ~/toolset/scripts/common.sh
source ~/toolset/scripts/install-nodejs.sh
install_nodejs
```

## Requirements

- **Operating System:** Ubuntu 20.04+ or Debian 10+
- **Privileges:** Root access (sudo)
- **Network:** Internet connection for package installation
- **Tools:** `curl` or `wget` (for one-line install)

## Contributing

Contributions are welcome. To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

### Adding a New Task

1. Create a new script in the `scripts/` directory
2. Follow the naming convention: `action-target.sh` (e.g., `install-redis.sh`)
3. Include a main function named after the script (e.g., `install_redis`)
4. Source `common.sh` for shared utilities
5. Add the task definition to `setup.sh`

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

For issues and feature requests, please open an issue on GitHub.

