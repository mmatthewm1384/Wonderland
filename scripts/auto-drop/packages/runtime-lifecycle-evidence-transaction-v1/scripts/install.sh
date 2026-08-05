#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"
BACKUP="$TARGET.runtime-lifecycle-evidence-transaction-v1.bak"

cp "$TARGET" "$BACKUP"

python3 - "$TARGET" <<'PY'
from pathlib import Path
import sys

target = Path(sys.argv[1])

text = target.read_text()

if "runtime-lifecycle.jsonl" in text:
    print("Lifecycle evidence already installed")
    raise SystemExit(0)

start = text.index("    def _event(")
end = text.index("\n\n\n    def _resolve_runtime", start)

replacement = '''    def _event(self, action, result):

        import json

        timestamp = datetime.now(
            timezone.utc
        ).isoformat()

        event = {
            "service": "runtime",
            "action": action,
            "timestamp": timestamp,
            "adapter": result,
        }

        evidence = (
            self.root
            / "runtime"
            / "events"
            / "runtime-lifecycle.jsonl"
        )

        evidence.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        with evidence.open("a") as f:
            f.write(
                json.dumps(event)
                + "\\\\n"
            )

        return event
'''

text = (
    text[:start]
    + replacement
    + text[end:]
)

target.write_text(text)

PY

python3 -m compileall "$TARGET"

echo "Runtime lifecycle evidence installed"
