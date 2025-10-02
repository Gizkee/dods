#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
echo "Restarting server..."
./scripts/stop.sh
./scripts/start.sh
echo "Server restarted."

