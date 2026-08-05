#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/state"

test -f "$TARGET/__init__.py"

python3 -m compileall "$TARGET"

echo "CERTIFIED"
