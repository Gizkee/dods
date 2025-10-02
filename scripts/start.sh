#!/usr/bin/env bash
set -euo pipefail

# Handle help option
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "=== Day of Defeat: Source Server - Environment Variables ==="
    echo ""
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
    echo "Usage examples:"
    echo "# Use default settings:"
    echo "./scripts/start.sh"
    echo ""
    echo "# Custom server name and players:"
    echo "DODS_HOSTNAME='My Custom Server' DODS_MAXPLAYERS=32 ./scripts/start.sh"
    echo ""
    echo "# Full customization:"
    echo "export DODS_HOSTNAME='My Server'"
    echo "export DODS_RCONPW='mypassword'"
    echo "export DODS_MAXPLAYERS=24"
    echo "./scripts/start.sh"
    exit 0
fi

cd "$(dirname "$0")/.."

echo "=== Starting Day of Defeat: Source Server ==="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please run ./setup/install-docker.sh first."
    exit 1
fi

# Check if user is in docker group
if ! groups $USER | grep -q docker; then
    echo "User is not in docker group. Please log out and log back in after running ./setup/install-docker.sh"
    echo "Or run: sudo usermod -aG docker $USER && newgrp docker"
    exit 1
fi

# Show environment variable info if no custom variables are set
if [ -z "${DODS_HOSTNAME:-}" ] && [ -z "${DODS_MAXPLAYERS:-}" ] && [ -z "${DODS_RCONPW:-}" ]; then
    echo "Using default server settings. You can customize by setting environment variables:"
    echo "Example: DODS_HOSTNAME='My Server' DODS_MAXPLAYERS=32 ./scripts/start.sh"
    echo "Run './scripts/start.sh --help' for full list of variables."
    echo ""
fi

# Stop and remove existing container if it exists
echo "Stopping existing container (if running)..."
docker stop dods-dedicated 2>/dev/null || true
docker rm dods-dedicated 2>/dev/null || true

# Build the image
echo "Building Docker image..."
docker build -t dods ./docker

# Run the container
echo "Starting DODS server container..."
docker run -d \
  --name dods-dedicated \
  --restart unless-stopped \
  -e DODS_HOSTNAME="${DODS_HOSTNAME}" \
  -e DODS_TICKRATE="${DODS_TICKRATE}" \
  -e DODS_PORT="${DODS_PORT}" \
  -e DODS_TV_PORT="${DODS_TV_PORT}" \
  -e DODS_MAXPLAYERS="${DODS_MAXPLAYERS}" \
  -e DODS_RCONPW="${DODS_RCONPW}" \
  -e DODS_PW="${DODS_PW}" \
  -e DODS_STARTMAP="${DODS_STARTMAP}" \
  -e DODS_CFG="${DODS_CFG}" \
  -e DODS_MAPCYCLE="${DODS_MAPCYCLE}" \
  -e DODS_FPSMAX="${DODS_FPSMAX}" \
  -v "$(pwd)/data:/home/steam/dods-dedicated" \
  -p "${DODS_PORT}:${DODS_PORT}/udp" \
  -p "${DODS_PORT}:${DODS_PORT}/tcp" \
  -p "${DODS_TV_PORT}:${DODS_TV_PORT}/udp" \
  dods

echo ""
echo "=== Server Started Successfully ==="
echo "Container: dods-dedicated"
echo "Server: ${DODS_HOSTNAME:-New DoD:S Server}"
echo "Port: ${DODS_PORT:-27015}"
echo ""
echo "Useful commands:"
echo "- View logs: ./scripts/logs.sh"
echo "- Stop server: ./scripts/stop.sh"  
echo "- Restart server: ./scripts/restart.sh"
echo ""
echo "The server will be available on port ${DODS_PORT:-27015}."
echo "First startup may take a few minutes while SteamCMD downloads the game files."
echo "Follow startup: ./scripts/logs.sh"

