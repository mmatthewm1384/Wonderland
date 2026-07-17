#!/usr/bin/env bash
set -euo pipefail


echo "== Add Runtime Capabilities =="


ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TARGET="$ROOT/builder/python/wlplatform/wlplatform/engines/catalog.py"


python3 - <<'PY'

from pathlib import Path


path = Path(
"builder/python/wlplatform/wlplatform/engines/catalog.py"
)


text = path.read_text()


old = '''
"architecture": {
'''


insert = '''
"runtime": {
    "class": "RuntimeEngine",
    "module": ".",
    "capabilities": [
        "runtime.start",
        "runtime.stop",
        "runtime.restart",
        "runtime.status",
        "runtime.sleep",
        "runtime.wake",
    ],
    "depends_on": [
        "registry",
        "architecture",
    ],
},

'''


if '"runtime": {' not in text:

    text = text.replace(
        old,
        insert + old
    )


path.write_text(text)

PY


echo "Runtime capabilities added"
