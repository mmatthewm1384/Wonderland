#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

RUNTIME="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime"

rm -rf "$RUNTIME/state"

if [[ -f "$RUNTIME/state.py.runtime-state-module-migration-v1.bak" ]]; then
    mv \
    "$RUNTIME/state.py.runtime-state-module-migration-v1.bak" \
    "$RUNTIME/state.py"
fi

echo "Rollback complete"
