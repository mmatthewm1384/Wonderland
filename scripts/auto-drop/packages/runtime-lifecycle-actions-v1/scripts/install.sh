#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/vault/08-Operations/runtime/lifecycle-actions.json"

mkdir -p "$(dirname "$TARGET")"

cat > "$TARGET" <<JSON
{
  "component": "runtime",
  "actions": [
    "start",
    "stop",
    "restart",
    "sleep",
    "wake"
  ],
  "governed": true,
  "certified": true
}
JSON

echo "Runtime lifecycle actions installed"
