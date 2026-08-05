#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"
PATCH="$(dirname "$0")/patches/runtime_service.py.patch"

if patch --dry-run -p1 -d "$WL_ROOT" < "$PATCH"; then
    patch -p1 -d "$WL_ROOT" < "$PATCH"
else
    echo "Patch cannot be applied cleanly"
    exit 1
fi

echo "runtime-certify-state-fix-v1 installed"
