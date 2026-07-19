#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "Searching EngineResult definition..."

ENGINE_RESULT=$(grep -R "class EngineResult" \
    builder/python/wlplatform/wlplatform \
    --include="*.py" \
    | head -1 \
    | cut -d: -f1)

if [ -z "$ENGINE_RESULT" ]; then
    echo "ERROR: EngineResult definition not found"
    exit 1
fi

echo "Found:"
echo "$ENGINE_RESULT"

MODULE=$(echo "$ENGINE_RESULT" \
    | sed \
        -e 's#builder/python/wlplatform/##' \
        -e 's#/#.#g' \
        -e 's#.py$##')

echo "Module:"
echo "$MODULE"

python3 - <<PY
from pathlib import Path

test = Path(
    "builder/python/wlplatform/wlplatform/tests/test_engine_contracts.py"
)

text = test.read_text()

lines = text.splitlines()

lines = [
    line
    for line in lines
    if not line.startswith(
        "from wlplatform.engine_result import"
    )
]

lines.insert(
    5,
    "from ${MODULE} import EngineResult",
)

test.write_text(
    "\\n".join(lines) + "\\n"
)

print("patched test import")
PY

echo
echo "Running engine contract regression..."

python3 -m pytest \
builder/python/wlplatform/wlplatform/tests/test_engine_contracts.py
