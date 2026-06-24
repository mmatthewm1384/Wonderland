#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/../compose.yaml"

echo "=== wl veil open ==="
nerdctl compose -f "${COMPOSE_FILE}" run --rm veil /bin/bash -c "/scripts/inside/veil-session.sh" || echo "Session fallback used."
echo "Session ended. Vault sealed."
