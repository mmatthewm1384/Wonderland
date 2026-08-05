#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

python3 -m compileall \
"$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"

echo CERTIFIED
