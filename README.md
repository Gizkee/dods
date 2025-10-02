# Day of Defeat: Source Dedicated Server (Docker)

This repository provides an easy setup to run a Day of Defeat: Source dedicated server using Docker. It includes sensible defaults, configuration templates, and helper scripts for quick deployment.

## Requirements

- Docker Engine 20+
- Ubuntu 20.04+ (other Linux distributions with Docker should also work)
- Git (automatically installed by bootstrap script if missing)

## Quick Start

### Prerequisites

On fresh Ubuntu installations, ensure `curl` is installed:

```bash
apt update && apt install -y curl
```

### Option 1: Bootstrap Script (Recommended)

Run this single command to clone the repository and get started:

```bash
curl -sSL https://raw.githubusercontent.com/Gizkee/dods/main/setup/bootstrap.sh | bash
```

This will:
- Clone the repository to `~/dods-server`
- Install git if missing
- Make all scripts executable
- Provide next-step instructions

### Option 2: Manual Setup

1. **Clone the repository**:
```bash
git clone https://github.com/Gizkee/dods.git ~/dods-server
cd ~/dods-server
chmod +x *.sh setup/*.sh
```

2. **Continue with setup steps below**

## Setup Steps

After running the bootstrap script or manual clone:

### 1. Create User (if needed, run as root)
```bash
sudo ./setup/setup-user.sh
```

### 2. Install Docker
```bash
./setup/install-docker.sh
```

### 3. Start the Server
```bash
./start.sh
```

## Server Management

- **Start server**: `./start.sh`
- **Stop server**: `./stop.sh`
- **Restart server**: `./restart.sh`
- **View logs**: `./logs.sh`

## Configuration

### Environment Variables

The server uses environment variables for configuration. You can set them before running the start script:

```bash
# Example with custom settings
DODS_HOSTNAME="My Custom Server" DODS_MAXPLAYERS=32 ./start.sh
```

Available variables (with defaults from Dockerfile):
- `DODS_HOSTNAME`: Server name (default: "New DoD:S Server")
- `DODS_RCONPW`: RCON password (default: "changeme")
- `DODS_PW`: Server password (default: "changeme")
- `DODS_PORT`: Server port (default: 27015)
- `DODS_TV_PORT`: SourceTV port (default: 27020)
- `DODS_MAXPLAYERS`: Maximum players (default: 16)
- `DODS_TICKRATE`: Server tickrate (default: 66)
- `DODS_STARTMAP`: Starting map (default: "dod_argentan")
- `DODS_FPSMAX`: Max FPS (default: 300)
- `DODS_CFG`: Config file (default: "server.cfg")
- `DODS_MAPCYCLE`: Map cycle file (default: "mapcycle.txt")

### Configuration Files

- `config/server.cfg`: Main server configuration (CVars)
- `config/mapcycle.txt`: Server map cycle list

Edit these files and restart the server to apply changes.

## Project Structure

```
config/
  server.cfg           # Server settings
  mapcycle.txt         # Map rotation
data/                  # Game files (downloaded automatically on first run)
docker/
  Dockerfile           # Docker image definition
  entry.sh             # Container entry point
setup/                 # Initial setup scripts (run once)
  bootstrap.sh         # Initial repository setup and cloning
  install-docker.sh    # Install Docker on Ubuntu
  setup-user.sh        # Create user with sudo access (run as root)
start.sh               # Start the server
stop.sh                # Stop the server  
restart.sh             # Restart the server
logs.sh                # Follow server logs
```

## Default Ports

- **27015/udp and 27015/tcp**: Game and RCON
- **27020/udp**: SourceTV

## Advanced Usage

### Persistent Configuration

For permanent configuration, you can set environment variables in your shell profile:

```bash
# Add to ~/.bashrc or ~/.zshrc
export DODS_HOSTNAME="My Permanent Server"
export DODS_MAXPLAYERS=24
export DODS_RCONPW="mysecretpassword"
```

### Custom Repository URL

The bootstrap script supports custom repository URLs:

```bash
DODS_REPO_URL="https://github.com/yourusername/your-dods-fork.git" \
curl -sSL https://raw.githubusercontent.com/Gizkee/dods/main/setup/bootstrap.sh | bash
```

### Custom Installation Directory

```bash
DODS_INSTALL_DIR="/opt/dods" \
curl -sSL https://raw.githubusercontent.com/Gizkee/dods/main/setup/bootstrap.sh | bash
```

## Server Updates

Valve updates are handled automatically by SteamCMD. To update your server:

```bash
./restart.sh
```

The container will run SteamCMD on startup and ensure the server is up-to-date before launching.

## Steam GSLT (Server Token)

- To appear on the public server list, set `DODS_PW` to empty and optionally get a Steam Game Server Login Token
- Create a token at https://steamcommunity.com/dev/managegameservers with App ID `300` (Day of Defeat: Source)
- For LAN-only servers, you can use the default settings

## Backups

All game files and server data are stored in the `data/` directory. Back up this folder to preserve:
- Downloaded game files
- Workshop content
- Server logs and data

## Troubleshooting

### Common Issues

- **Ports in use**: Change `DODS_PORT` environment variable and restart
- **First boot is slow**: Server downloads game files via SteamCMD (normal)
- **Permission errors**: Ensure scripts are executable with `chmod +x *.sh setup/*.sh`
- **Docker daemon not running**: 
  - Error: `Cannot connect to Docker daemon at unix:///var/run/docker.sock`
  - Solution: `sudo service docker start` or ensure Docker Desktop is running
  - WSL users: Make sure Docker Desktop is running on Windows
- **User not in docker group**: Log out and back in after running install-docker.sh

### Reset to Clean Install

```bash
./stop.sh
sudo rm -rf data/
./start.sh
```

### View Container Status

```bash
docker ps
docker logs dods-dedicated
```

## Uninstall

```bash
./stop.sh
docker rmi dods
rm -rf ~/dods-server
```

## Development

### Building Custom Image

```bash
docker build -t dods ./docker
```

### Running with Custom Settings

```bash
docker run -d \
  --name dods-dedicated \
  -e DODS_HOSTNAME="Test Server" \
  -e DODS_MAXPLAYERS=8 \
  -p 27015:27015/udp \
  -p 27015:27015/tcp \
  -p 27020:27020/udp \
  -v "$(pwd)/data:/home/steam/dods-dedicated" \
  dods
```

## Contributing

Feel free to submit issues and pull requests to improve this setup!

## License

This project is open source. The Day of Defeat: Source server files are owned by Valve Corporation.