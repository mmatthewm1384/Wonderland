#!/usr/bin/env bash

set -euo pipefail

ROOT="${WL_ROOT:?WL_ROOT is required}"

SOURCE="payload/scripts/auto-drop/lib/root.sh"
TARGET="$ROOT/scripts/auto-drop/lib/root.sh"

if [[ ! -f "$SOURCE" ]]; then
    echo "ERROR: Missing payload root.sh"
    exit 1
fi

mkdir -p "$(dirname "$TARGET")"

cp "$SOURCE" "$TARGET"

chmod +x "$TARGET"

echo "Auto-Drop Core installed"
