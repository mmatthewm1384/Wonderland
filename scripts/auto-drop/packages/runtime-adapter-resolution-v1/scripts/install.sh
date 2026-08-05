#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"

BACKUP="${TARGET}.runtime-adapter-resolution-v1.bak"

cp "$TARGET" "$BACKUP"

restore() {
    cp "$BACKUP" "$TARGET"
}

trap restore ERR

python3 <<PY
from pathlib import Path

p = Path("$TARGET")
text = p.read_text()

if "_adapter_for" not in text:
    raise SystemExit(
        "RuntimeService adapter resolver missing"
    )

start = text.index("    def _adapter_for")

end = text.find(
    "\n    def ",
    start + 10
)

if end == -1:
    end = len(text)

replacement = '''
    def _adapter_for(self, target=None):

        if target in (None, "host", "wonderland-rootless"):
            from wlplatform.runtime.adapters.lima_adapter import (
                LimaRuntimeAdapter
            )

            return LimaRuntimeAdapter(
                "wonderland-rootless"
            )

        if target == "debian":
            from wlplatform.runtime.adapters.lima_adapter import (
                LimaRuntimeAdapter
            )

            return LimaRuntimeAdapter(
                "wonderland-debian-rootless-v1"
            )

        return None
'''

text = (
    text[:start]
    + replacement
    + text[end:]
)

p.write_text(text)
PY

python3 -m compileall "$TARGET"

rm -f "$BACKUP"

echo "Runtime adapter resolver installed"
