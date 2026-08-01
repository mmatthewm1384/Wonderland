#!/usr/bin/env bash

set -euo pipefail

ROOT="${WL_ROOT:?WL_ROOT is required}"

TARGET="$ROOT/scripts/auto-drop/lib/root.sh"

if [[ ! -f "$TARGET" ]]; then
    echo "FAIL: Missing root.sh"
    exit 1
fi

if [[ ! -x "$TARGET" ]]; then
    echo "FAIL: root.sh not executable"
    exit 1
fi

echo "Auto-Drop Core verification PASS"
