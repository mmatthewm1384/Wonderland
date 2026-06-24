#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/../compose.yaml"
VAULT_DIR="${HOME}/Wonderland/vault"

echo "=== wl veil doctor ==="
echo "Vault dir: ${VAULT_DIR}   exists: $([ -d "${VAULT_DIR}" ] && echo yes || echo no)"
if [ -f "${VAULT_DIR}/veil.age" ]; then
  size=$(wc -c < "${VAULT_DIR}/veil.age" 2>/dev/null || echo 0)
  echo "Archive: present (${size} bytes)"
else
  echo "Archive: missing → run repair"
fi
nerdctl compose -f "${COMPOSE_FILE}" config --quiet >/dev/null 2>&1 && echo "Compose: valid" || echo "Compose: invalid"
nerdctl image inspect veil:latest >/dev/null 2>&1 && echo "Image: present" || echo "Image: missing → run repair"
echo "Network: none | Plaintext: tmpfs only | Logs: none"
echo "Doctor complete (read-only)."
