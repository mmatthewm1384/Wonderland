#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "== Wonderland Engine Registry Factory Adapter Repair =="


TARGET="$ROOT/builder/python/wlplatform/wlplatform/engines/factory.py"


if [ ! -f "$TARGET" ]; then
    echo "Missing factory:"
    echo "$TARGET"
    exit 1
fi


cp "$TARGET" \
"$TARGET.bak.registry-adapter.$(date +%Y%m%d-%H%M%S)"


python3 <<'PY'
from pathlib import Path

path = Path(
"builder/python/wlplatform/wlplatform/engines/factory.py"
)

text = path.read_text()


old = '''
    for entry in engines:
        if entry["name"] == name:
            return entry["class"](root)
'''


new = '''
    if isinstance(engines, dict):

        engines = [
            {
                "name": key,
                **value
            }
            for key, value in engines.items()
        ]


    for entry in engines:

        if entry.get("name") == name:

            return entry["class"](root)
'''


if old not in text:
    raise SystemExit(
        "Factory patch point not found"
    )


path.write_text(
    text.replace(old, new)
)

print("Factory adapter patched")

PY


echo "Compile verification"

python3 -m compileall \
"$TARGET" \
>/dev/null


echo "PASS"
