#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SOURCE="$ROOT/artifacts/wl-runtime-lima-readiness/lima.py"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters/lima.py"

BACKUP="$TARGET.before-runtime-lima-readiness-hardening"

echo "RUNTIME LIMA READINESS INSTALL"
echo "=============================="

if [[ ! -f "$SOURCE" ]]; then
    echo "ERROR: artifact missing"
    exit 1
fi

if [[ -f "$TARGET" ]]; then
    cp "$TARGET" "$BACKUP"
fi

cp "$SOURCE" "$TARGET"

echo "Installed:"
echo "$TARGET"

echo "INSTALL PASS"
