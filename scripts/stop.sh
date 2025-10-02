#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
docker stop dods-dedicated 2>/dev/null || true
docker rm dods-dedicated 2>/dev/null || true
echo "Server stopped."

