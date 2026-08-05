#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

RUNTIME="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime"

test -d "$RUNTIME/state"
test -f "$RUNTIME/state/__init__.py"

python3 -m compileall "$RUNTIME"

echo "CERTIFIED"
