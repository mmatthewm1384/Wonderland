#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

RUNTIME="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime"

OLD="$RUNTIME/state.py"
BACKUP="$RUNTIME/state.py.runtime-state-module-migration-v1.bak"

if [[ -f "$OLD" ]]; then
    mv "$OLD" "$BACKUP"
fi

mkdir -p "$RUNTIME/state"

cat > "$RUNTIME/state/__init__.py" <<'PY'
from .store import RuntimeStateStore

__all__ = [
    "RuntimeStateStore"
]
PY

python3 -m compileall "$RUNTIME"

echo "Runtime state namespace migrated"
