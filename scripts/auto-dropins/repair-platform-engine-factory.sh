#!/usr/bin/env bash
set -euo pipefail

echo "== Repair Platform Engine Factory =="

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

cd "$ROOT"

export PYTHONPATH="$ROOT/builder/python/wlplatform"

python3 - <<'PY'

from pathlib import Path

target = Path(
"builder/python/wlplatform/wlplatform/engine_router.py"
)

text = target.read_text()

old = """
from .engines import get_engine
"""

if old not in text:
    print("Factory import already repaired")
    exit(0)


text=text.replace(
old,
"""
from .engines import get_engine
"""
)

target.write_text(text)

print("Factory import verified")

PY


echo "DONE"
