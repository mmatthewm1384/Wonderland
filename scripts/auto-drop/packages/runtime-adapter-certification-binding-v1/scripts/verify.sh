#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters/lima_adapter.py"

python3 -m compileall "$TARGET"

grep -q "RuntimeCertificationResolver" "$TARGET"

echo "CERTIFIED"
