#!/usr/bin/env bash
set -euo pipefail

echo "Restarting server..."
./stop.sh
./start.sh
echo "Server restarted."

