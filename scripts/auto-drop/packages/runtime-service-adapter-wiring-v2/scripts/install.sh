#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"

BACKUP="${TARGET}.runtime-service-adapter-wiring-v2.bak"

cp "$TARGET" "$BACKUP"

restore() {
    cp "$BACKUP" "$TARGET"
}

trap restore ERR

python3 <<PY
from pathlib import Path

p = Path("$TARGET")
text = p.read_text()

if "LimaRuntimeAdapter" in text:
    print("Adapter already wired")
    raise SystemExit(0)

text = text.replace(
"from wlplatform.runtime.targets.loader import RuntimeTargetRegistry",
"""from wlplatform.runtime.targets.loader import RuntimeTargetRegistry
from wlplatform.runtime.adapters.lima_adapter import LimaRuntimeAdapter"""
)

if "self.adapter =" not in text:

    marker = "class RuntimeService:"

    inject = """

    def _get_adapter(self):
        return LimaRuntimeAdapter()

"""

    text = text.replace(
        marker,
        marker + inject
    )

p.write_text(text)
PY

python3 -m compileall "$TARGET"

rm -f "$BACKUP"

echo "Runtime service adapter wiring installed"
