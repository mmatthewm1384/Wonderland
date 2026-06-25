#!/usr/bin/env bash
set -euo pipefail

WL_HOME="${WL_HOME:-$HOME/Wonderland}"
BACKUP="/Users/wonderland/Wonderland/.backup-wl-consolidation-20260621-171654"

if [[ -f "$BACKUP/wl.previous" ]]; then
  cp "$BACKUP/wl.previous" "$WL_HOME/bin/wl"
  chmod +x "$WL_HOME/bin/wl"
  echo "Rolled back bin/wl from $BACKUP/wl.previous"
else
  echo "No previous wl found in $BACKUP"
  exit 1
fi
