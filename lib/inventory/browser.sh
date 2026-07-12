#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
OUT="$WL_HOME/vault/08-Operations/platform/browser/browser-inventory-latest.json"

mkdir -p "$(dirname "$OUT")"

"$WL_HOME/bin/wl-browser" status-json > "$OUT"

echo "PASS browser inventory: $OUT"
