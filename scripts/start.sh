#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  echo "No .env found. Creating one from env.example..."
  cp env.example .env
  echo "Created .env. You can edit it to customize the server."
fi

docker compose up -d --build
echo "Server starting. Follow logs with ./scripts/logs.sh"

