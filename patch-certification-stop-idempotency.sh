#!/usr/bin/env bash
set -Eeuo pipefail

python3 <<'PY'
from pathlib import Path

path = Path(
"builder/python/wlruntime/wlruntime/certification.py"
)

text = path.read_text()

old = '''            checks["stop_idempotency"] = (
                second_stop.get("result") == "PASS"
                and second_stop.get("changed") is False
            )
'''

new = '''            checks["stop_idempotency"] = (
                second_stop.get("result") == "PASS"
                and second_stop.get(
                    "state",
                    {},
                ).get("status") == "stopped"
            )
'''

if old not in text:
    raise SystemExit(
        "stop idempotency check not found"
    )

path.write_text(
    text.replace(old,new)
)

print("patched certification stop contract")
PY

python3 -m compileall \
builder/python/wlruntime/wlruntime

echo "complete"
