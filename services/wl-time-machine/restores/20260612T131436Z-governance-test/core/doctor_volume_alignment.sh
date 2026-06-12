#!/usr/bin/env bash
set -euo pipefail

VAULT_SCRIPT="/Users/wonderland/Wonderland/bin/wl-vault"

echo "=== 🩺 Verifying Cryptographic Volume Alignment ==="

if [ ! -f "$VAULT_SCRIPT" ]; then
    echo "[FAIL] wl-vault engine script missing."
    exit 1
fi

# Audit the script content to ensure it targets Wonderland_Secret_Zone
if grep -q "VOLUME_NAME=\"Wonderland_Secret_Zone\"" "$VAULT_SCRIPT"; then
    echo "[OK] Volatile memory layer properly targets /Volumes/Wonderland_Secret_Zone."
else
    echo "[FAIL] Unexpected volume naming alignment discovered inside wl-vault."
    exit 1
fi

echo "=== VOLUME ALIGNMENT VALIDATED ==="
