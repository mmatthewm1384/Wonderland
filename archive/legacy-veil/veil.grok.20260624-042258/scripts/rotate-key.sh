#!/bin/bash
set -euo pipefail
VAULT="${HOME}/Wonderland/vault/veil.age"
OLD_KEY="age-key.txt"

if [ ! -f "${VAULT}" ]; then
  echo "No vault to rotate."
  exit 0
fi

if [ ! -f "${OLD_KEY}" ]; then
  echo "ERROR: Old key missing. Use repair or restore from backup."
  exit 1
fi

echo "Rotating age key..."
age-keygen -o new-age-key.txt
age -d -i "${OLD_KEY}" "${VAULT}" | age -R new-age-key.txt -o "${VAULT}.new"
mv "${VAULT}.new" "${VAULT}"
mv "${OLD_KEY}" "old-key-$(date +%s).txt"
echo "Key rotation complete. Old key archived."
