#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"

BACKUP="${TARGET}.runtime-state-store-wiring-v1.bak"

cp "$TARGET" "$BACKUP"

restore() {
    cp "$BACKUP" "$TARGET"
}

trap restore ERR

python3 <<PY
from pathlib import Path

p = Path("$TARGET")

text = p.read_text()

if "RuntimeStateStore" in text:
    print("State store already wired")
    raise SystemExit(0)

text = text.replace(
"from wlplatform.runtime.targets.loader import RuntimeTargetRegistry",
"""from wlplatform.runtime.targets.loader import RuntimeTargetRegistry
from wlplatform.runtime.state.store import RuntimeStateStore"""
)

marker = "class RuntimeService:"

if marker not in text:
    raise SystemExit(
        "RuntimeService class missing"
    )

text = text.replace(
marker,
marker + """

    def _state_store(self):
        return RuntimeStateStore(
            self.root
        )

"""
)

p.write_text(text)
PY

python3 -m compileall "$TARGET"

rm -f "$BACKUP"

echo "Runtime state wiring installed"
