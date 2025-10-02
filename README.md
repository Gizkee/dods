### Day of Defeat: Source Dedicated Server (Docker + Docker Compose)

This repository provides an easy, one-command setup to run a Day of Defeat: Source dedicated server using Docker and Docker Compose. It includes sensible defaults, configuration templates, and helper scripts so anyone can deploy quickly—even with very basic computer knowledge.

### Requirements
- Docker (Engine) 20+
- Docker Compose v2+
- Ubuntu 20.04+ (other OSes with Docker should also work)

### Remote Server Deployment
For deploying on a fresh Ubuntu server:

#### Option 1: Complete Automated Setup (Recommended)
1) **SSH into your Ubuntu server as root** and run the complete setup:
```bash
# Download and run the complete setup (creates user, installs Docker, configures everything)
curl -fsSL https://raw.githubusercontent.com/your-repo/dodsmylife/main/scripts/initial-server-setup.sh | bash
```

2) **Switch to the DODS user**:
```bash
su - dods
```

3) **Copy your DODS server files** to the server:
```bash
cd ~/dods-server
# Copy all files from this repository to ~/dods-server/
```

4) **Start the server**:
```bash
./scripts/start.sh
```

#### Option 2: Manual User Setup
If you need to create a user with sudo access first:

1) **SSH into your Ubuntu server as root** and run the user setup:
```bash
# Download and run user setup
curl -fsSL https://raw.githubusercontent.com/your-repo/dodsmylife/main/scripts/setup-user.sh | bash
```

2) **Switch to the new user** and run the server setup:
```bash
su - your-username
./scripts/remote-setup.sh
```

#### Option 3: Step-by-Step Setup
1) **SSH into your Ubuntu server** and run the setup script:
```bash
# Download and run the complete setup
curl -fsSL https://raw.githubusercontent.com/your-repo/dodsmylife/main/scripts/remote-setup.sh | bash
```

2) **Log out and log back in** for Docker group changes to take effect.

3) **Copy your DODS server files** to the server (or clone the repository):
```bash
cd ~/dods-server
# Copy all files from this repository to ~/dods-server/
```

4) **Configure and start the server**:
```bash
# Edit configuration
nano .env

# Start the server
./scripts/start.sh
```

### Local Development
For running locally on your machine:

### Quick Start
1) Open a terminal and navigate to this project folder.

2) Copy the example environment file and optionally edit it:
```bash
cp env.example .env
```

3) Start the server:
```bash
./scripts/start.sh
```

The first run will download the game server via SteamCMD. This can take a few minutes depending on your internet speed.

### Default Ports
- 27015/udp and 27015/tcp: Game and RCON
- 27020/udp: SourceTV

If you need to change ports, edit `.env` and then restart with `./scripts/restart.sh`.

### Configuration Files
- `config/server.cfg`: Main server configuration (CVars). This file will be mounted into the container at runtime.
- `config/mapcycle.txt`: The server map cycle list.

Edit these files locally, then restart the server with `./scripts/restart.sh` to apply changes.

### Folder Structure
```
config/
  server.cfg           # Server settings
  mapcycle.txt         # Map rotation
data/                  # Game files (downloaded automatically on first run)
docker/
  Dockerfile
  entrypoint.sh
scripts/
  start.sh             # Start or create the server
  stop.sh              # Stop the server
  restart.sh           # Restart the server
  logs.sh              # Follow server logs
  common.sh            # Shared functions for all scripts
  setup-server.sh      # Initial Ubuntu server setup
  deploy.sh            # Deploy server after setup
  remote-setup.sh      # Complete remote server setup
  setup-user.sh        # Create user with sudo access (run as root)
  initial-server-setup.sh # Complete initial setup (run as root)
.env.example           # Example environment variables
docker-compose.yml
```

### Environment Variables
The most common settings are in `.env`:
- `SERVER_NAME`: Public name of your server
- `SERVER_PORT`: Port to listen on (default 27015)
- `RCON_PASSWORD`: RCON password
- `MAX_PLAYERS`: Max players (e.g., 24)
- `TICKRATE`: Server tickrate (recommended 66)
- `START_MAP`: Initial map to load (e.g., `dod_donner`)
- `SRCDS_ADDITIONAL_ARGS`: Extra arguments to pass to the server

### Common Commands
- Start: `./scripts/start.sh`
- Stop: `./scripts/stop.sh`
- Restart: `./scripts/restart.sh`
- Logs: `./scripts/logs.sh`

### Server Setup Commands
- **Complete initial setup** (root): `./scripts/initial-server-setup.sh`
- **User setup only** (root): `./scripts/setup-user.sh`
- **Server setup only**: `./scripts/setup-server.sh`
- **Deploy after setup**: `./scripts/deploy.sh`
- **Complete remote setup**: `./scripts/remote-setup.sh`

### Script Architecture
All setup scripts now use shared functions from `common.sh` to eliminate duplication:
- **Common functions**: System updates, Docker installation, firewall configuration
- **Modular design**: Each script focuses on its specific purpose
- **Consistent logging**: Color-coded output for better user experience
- **Error handling**: Proper validation and error messages

### Updating the Server
Valve updates are handled by SteamCMD. To update:
```bash
./scripts/restart.sh
```
The container will run SteamCMD on startup and ensure the server is up-to-date before launching.

### Notes on Steam GSLT (Server Token)
- To appear on the public server list reliably, set `STEAM_GSLT` in `.env` using a token created at `https://steamcommunity.com/dev/managegameservers` with App ID `300` (Day of Defeat: Source).
- If you only play on a LAN, you can leave `STEAM_GSLT` empty and set `SRCDS_ADDITIONAL_ARGS="+sv_lan 1"`.

### Backups
All downloaded game files and server data live in `data/`. Back up this folder to preserve your installation, downloaded workshop content, and any saved data.

### Uninstall
```bash
./scripts/stop.sh
docker compose down --volumes
```
Then remove this project folder if you wish.

### Troubleshooting
- If ports are in use, change `SERVER_PORT` in `.env` and restart.
- First boot takes time while the server downloads—this is normal.
- To reset to a clean install, stop the server and delete the `data/` folder, then start again.


