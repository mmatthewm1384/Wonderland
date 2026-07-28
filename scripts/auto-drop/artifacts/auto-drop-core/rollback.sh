#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

rm -f "$ROOT/scripts/auto-drop/lib/root.sh"

rm -rf \
"$ROOT/vault/08-Operations/evidence/auto-drop-core" \
"$ROOT/vault/08-Operations/certifications/auto-drop-core"

echo "Auto-Drop Core rolled back"
