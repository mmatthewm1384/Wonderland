#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

SOURCE="$WL_ROOT/scripts/auto-drop/packages/auto-drop-verifier-library-v2/verifier.sh"
TARGET="$WL_ROOT/scripts/auto-drop/lib/verifier.sh"

if [[ ! -f "$SOURCE" ]]; then
    echo "ERROR: verifier source missing"
    exit 1
fi

cp "$SOURCE" "$TARGET"

chmod +x "$TARGET"

echo "PASS: canonical verifier installed"
