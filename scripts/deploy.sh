#!/usr/bin/env bash
set -euo pipefail

# DODS Server Deployment Script
# Run this after setup-server.sh to deploy the game server

echo "=== Day of Defeat: Source Server Deployment ==="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please run ./scripts/setup-server.sh first."
    exit 1
fi

# Check if user is in docker group
if ! groups $USER | grep -q docker; then
    echo "User is not in docker group. Please log out and log back in after running setup-server.sh"
    exit 1
fi

# Create project directory if it doesn't exist
mkdir -p ~/dods-server
cd ~/dods-server

# Clone or update the repository
if [ -d ".git" ]; then
    echo "Updating existing repository..."
    git pull
else
    echo "Cloning repository..."
    # Note: Replace with your actual repository URL
    echo "Please clone your repository here first:"
    echo "git clone <your-repo-url> ."
    echo "Or copy the files manually to ~/dods-server/"
    exit 1
fi

echo "You can customize the server by setting environment variables before running start.sh"
echo "Available environment variables:"
echo "- DODS_HOSTNAME: Your server's public name (default: 'My DODS Server')"
echo "- DODS_RCONPW: RCON password (default: 'changeme')"
echo "- DODS_PORT: Server port (default: 27015)"
echo "- DODS_MAXPLAYERS: Maximum players (default: 24)"
echo "- And more... see start.sh for full list"
echo ""
echo "Example: DODS_HOSTNAME='My Custom Server' DODS_RCONPW='mypassword' ./scripts/start.sh"

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
