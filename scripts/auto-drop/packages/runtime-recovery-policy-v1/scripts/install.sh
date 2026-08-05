#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"

BACKUP="$TARGET.runtime-recovery-policy-v1.backup"

cp "$TARGET" "$BACKUP"

python3 - "$TARGET" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

text = path.read_text()

if "def _normalize_runtime_result" in text:
    print("helper already exists")
    raise SystemExit(0)

marker = "    def _event(self, action, result):"

if marker not in text:
    raise SystemExit(
        "runtime event marker missing"
    )

helper = '''    def _normalize_runtime_result(
        self,
        action,
        result
    ):

        if result is True:
            state = "success"

        elif result is False:
            if action == "stop":
                state = "already_stopped"
            else:
                state = "failed"

        else:
            state = "unknown"

        return {
            "action": action,
            "raw_result": result,
            "state": state,
            "recoverable": state != "unknown"
        }


'''

text = text.replace(
    marker,
    helper + marker
)

path.write_text(text)

print("helper installed")
PY

python3 -m compileall "$TARGET"

echo "runtime recovery policy installed"
