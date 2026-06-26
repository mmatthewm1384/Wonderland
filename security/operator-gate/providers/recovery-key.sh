#!/usr/bin/env bash
set -euo pipefail

SECRET="$HOME/Wonderland/security/operator-gate/recovery-key.secret"

if [ ! -f "$SECRET" ]; then
  echo "DENY recovery-key missing"
  exit 1
fi

chmod 600 "$SECRET"

# Local possession check.
test -s "$SECRET"

echo "PASS recovery-key"
