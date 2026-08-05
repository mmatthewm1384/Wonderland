#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

FILE="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"

python3 - "$FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

text = path.read_text()

if "RuntimeEvidenceWriter" not in text:

    text = text.replace(
        "from ..runtime.inventory import RuntimeInventory",
        "from ..runtime.inventory import RuntimeInventory\n"
        "from ..runtime.evidence import RuntimeEvidenceWriter"
    )

old = '''    def _event(self, action, result):

        return {
            "service": "runtime",
            "action": action,
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat(),
            "adapter": result,
        }
'''

new = '''    def _event(self, action, result):

        writer = RuntimeEvidenceWriter(
            self.root
        )

        event = writer.write(
            action,
            result
        )

        return event
'''

if old not in text:
    raise SystemExit(
        "runtime event block not found"
    )

text = text.replace(
    old,
    new
)

path.write_text(text)

print("Runtime evidence binding applied")
PY

python3 -m compileall "$FILE"
