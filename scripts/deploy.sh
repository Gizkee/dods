#!/usr/bin/env bash
set -euo pipefail

# DODS Server Deployment Script
# Run this after install-docker.sh to deploy the game server

echo "=== Day of Defeat: Source Server Deployment ==="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please run ./scripts/install-docker.sh first."
    exit 1
fi

# Check if user is in docker group
if ! groups $USER | grep -q docker; then
    echo "User is not in docker group. Please log out and log back in after running install-docker.sh"
    exit 1
fi

# Create project directory if it doesn't exist
mkdir -p ~/dods
cd ~/dods

# Clone or update the repository
if [ -d ".git" ]; then
    echo "Updating existing repository..."
    git pull
else
    echo "Cloning repository..."
    # Note: Replace with your actual repository URL
    echo "Please clone your repository here first:"
    echo "git clone <your-repo-url> ."
    echo "Or copy the files manually to ~/dods/"
    exit 1
fi

echo "You can customize the server by setting environment variables before running start.sh"
echo "Available environment variables (with Dockerfile defaults):"
echo "- DODS_HOSTNAME: Your server's public name (default: 'New DoD:S Server')"
echo "- DODS_RCONPW: RCON password (default: 'changeme')"
echo "- DODS_PW: Server password (default: 'changeme')"
echo "- DODS_PORT: Server port (default: 27015)"
echo "- DODS_TV_PORT: SourceTV port (default: 27020)"
echo "- DODS_MAXPLAYERS: Maximum players (default: 16)"
echo "- DODS_TICKRATE: Server tickrate (default: 66)"
echo "- DODS_STARTMAP: Starting map (default: 'dod_argentan')"
echo "- DODS_FPSMAX: Max FPS (default: 300)"
echo "- DODS_CFG: Config file (default: 'server.cfg')"
echo "- DODS_MAPCYCLE: Map cycle file (default: 'mapcycle.txt')"
echo ""
echo "Example: DODS_HOSTNAME='My Custom Server' DODS_RCONPW='mypassword' DODS_MAXPLAYERS=32 ./scripts/start.sh"

# Make scripts executable
chmod +x scripts/*.sh

# Start the server
echo "Starting DODS server..."
./scripts/start.sh

echo ""
echo "=== Deployment Complete ==="
echo "Your Day of Defeat: Source server is starting up!"
echo ""
echo "Useful commands:"
echo "- View logs: ./scripts/logs.sh"
echo "- Stop server: ./scripts/stop.sh"
echo "- Restart server: ./scripts/restart.sh"
echo ""
echo "The server will be available on port 27015 (or your configured port)."
echo "First startup may take a few minutes while SteamCMD downloads the game files."
