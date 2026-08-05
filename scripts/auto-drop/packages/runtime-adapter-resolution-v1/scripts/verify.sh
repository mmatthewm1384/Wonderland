#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"

python3 -m compileall "$TARGET"

grep -q "_adapter_for" "$TARGET"

echo "CERTIFIED"
