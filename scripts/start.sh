#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Stop and remove existing container if it exists
docker stop dods-dedicated 2>/dev/null || true
docker rm dods-dedicated 2>/dev/null || true

# Build the image
docker build -t dods-server ./docker

# Run the container
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
  dods-server

echo "Server starting. Follow logs with ./scripts/logs.sh"

