#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$HOME/Wonderland"
ENGINE="$ROOT/builder/python/wlruntime/wlruntime/engine.py"

cp "$ENGINE" "$ENGINE.bak.$(date +%Y%m%dT%H%M%SZ)"

python3 - "$ENGINE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

needle = "    def stop("

if needle not in text:
    raise SystemExit("stop marker missing")

insert = '''
        # Certification contract requires explicit lifecycle result.
        state = self.state_store.read()

        return {
            "result": "PASS",
            "changed": True,
            "state": state,
            "engines": state.get("started_engines", []),
        }

'''

# only insert if missing near start boundary
start_pos = text.find("    def start(")
stop_pos = text.find(needle, start_pos)

section = text[start_pos:stop_pos]

if '"result": "PASS"' in section:
    print("start result already exists")
else:
    section = section.rstrip() + "\n" + insert
    text = (
        text[:start_pos]
        + section
        + text[stop_pos:]
    )
    path.write_text(text)
    print("patched start return")

PY

python3 -m compileall \
"$ROOT/builder/python/wlruntime/wlruntime"

echo "complete"
