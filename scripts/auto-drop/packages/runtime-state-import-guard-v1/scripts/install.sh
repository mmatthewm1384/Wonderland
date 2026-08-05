#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"

python3 <<PY
from pathlib import Path

p = Path("$TARGET")

text = p.read_text()

old = "from wlplatform.runtime.state.store import RuntimeStateStore"

if old in text:
    text = text.replace(
        old,
        """try:
    from wlplatform.runtime.state.store import RuntimeStateStore
except ImportError:
    RuntimeStateStore = None
"""
    )

p.write_text(text)
PY

python3 -m compileall "$TARGET"

echo "Import guard installed"
