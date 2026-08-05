#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

test -f \
"$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters/lima_adapter.py"

python3 -m compileall \
"$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters/lima_adapter.py"

echo "CERTIFIED"
