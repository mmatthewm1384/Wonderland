#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/state"

mkdir -p "$TARGET"

cat > "$TARGET/__init__.py" <<'PY'
from .store import RuntimeStateStore

__all__ = [
    "RuntimeStateStore"
]
PY

python3 -m compileall "$TARGET"

echo "Runtime state package fixed"
