#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${WL_HOME:-$(pwd)}"

python3 <<'PY'
from pathlib import Path

path = Path(
"builder/python/wlruntime/wlruntime/engine.py"
)

text = path.read_text()

old = '''            return {
                "result": "PASS",
                "action": "restart",
                "stop": stop_result,
                "start": start_result,
            }
'''

new = '''            state = self.state_store.read()

            return {
                "result": "PASS",
                "action": "restart",
                "stop": stop_result,
                "start": start_result,
                "state": state,
            }
'''

if old not in text:
    raise SystemExit(
        "restart return block not found"
    )

text = text.replace(old,new)

path.write_text(text)

print("patched restart state")
PY

python3 -m compileall \
builder/python/wlruntime/wlruntime

echo "complete"
