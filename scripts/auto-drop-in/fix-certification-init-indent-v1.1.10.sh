#!/usr/bin/env bash
set -euo pipefail

FILE="builder/python/wlplatform/wlplatform/certification/__init__.py"

python3 - <<'PY'
from pathlib import Path

p = Path("builder/python/wlplatform/wlplatform/certification/__init__.py")

text = p.read_text()

text = text.replace("\t", "    ")

p.write_text(text)

print("patched indentation")
PY

python3 -m py_compile "$FILE"

echo "PASS"
