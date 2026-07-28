#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"

source "$ROOT/scripts/auto-drop/lib/root.sh"

RESULT="$(wl_root)"

if [[ "$RESULT" != "$ROOT" ]]; then
    echo "FAIL: Root resolver mismatch"
    exit 1
fi

echo "Auto-Drop Root Resolver PASS"
