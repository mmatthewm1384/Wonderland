#!/usr/bin/env bash
set -euo pipefail

ROOT="${WL_HOME:-$HOME/Wonderland}"
STATE="$ROOT/vault/chaos/environment-state.json"
VISUAL="$ROOT/ephemeral/bin/wl-visual-chaos"

matrix="$(jq -r '.effects.matrix // false' "$STATE" 2>/dev/null || echo false)"
model="$(jq -r '.model // "unknown"' "$STATE" 2>/dev/null || echo unknown)"
intensity="$(jq -r '.effects.intensity // 0' "$STATE" 2>/dev/null || echo 0)"
motion="$(jq -r '.effects.motion // "none"' "$STATE" 2>/dev/null || echo none)"

if [[ "$matrix" == "true" ]]; then
  "$VISUAL" launch-all
  echo "PASS matrix controller applied model=$model intensity=$intensity motion=$motion"
else
  echo "PASS matrix controller inactive model=$model"
fi
