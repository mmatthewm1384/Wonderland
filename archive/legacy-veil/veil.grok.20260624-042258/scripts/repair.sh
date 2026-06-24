#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/../compose.yaml"
VAULT_DIR="${HOME}/Wonderland/vault"

echo "=== wl veil repair ==="
mkdir -p "${VAULT_DIR}"
nerdctl compose -f "${COMPOSE_FILE}" build
echo "Image ready."

if [ ! -f "${VAULT_DIR}/veil.age" ]; then
  echo "Creating initial vault."
  nerdctl compose -f "${COMPOSE_FILE}" run --rm veil bash -c '
    set -e
    mkdir -p /work/veil
    printf "# Wonderland Veil\n\n" > /work/veil/README.md
    (cd /work/veil && tar --owner=0 --group=0 --mtime="@0" --sort=name -czf - .) | age -p -o /vault/veil.age
  '
else
  echo "Archive exists."
fi
echo "Repair complete."
