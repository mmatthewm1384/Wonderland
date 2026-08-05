#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"

BACKUP="$TARGET.runtime-evidence-binding-backup"

cp "$TARGET" "$BACKUP"

python3 - "$TARGET" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

lines = path.read_text().splitlines()

start = None
end = None

for i,line in enumerate(lines):
    if line.startswith("    def _event("):
        start=i

    elif start is not None and i>start:
        if line.startswith("    def ") and not line.startswith("    def _event"):
            end=i
            break

if start is None:
    raise SystemExit(
        "event method not found"
    )

if end is None:
    end=len(lines)

replacement = [
"    def _event(self, action, result):",
"",
"        from ..runtime.evidence import RuntimeEvidenceWriter",
"",
"        writer = RuntimeEvidenceWriter(",
"            self.root",
"        )",
"",
"        return writer.write(",
"            action,",
"            result",
"        )",
"",
]

lines[start:end]=replacement

path.write_text(
    "\n".join(lines)+"\n"
)

print("patched")
PY

python3 -m compileall "$TARGET"
