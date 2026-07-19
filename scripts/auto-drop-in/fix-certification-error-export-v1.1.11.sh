#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

INIT="builder/python/wlplatform/wlplatform/certification/__init__.py"
ERRORS="builder/python/wlplatform/wlplatform/certification/errors.py"

echo "Fixing CertificationError export boundary..."

python3 - <<'PY'
from pathlib import Path

init = Path(
    "builder/python/wlplatform/wlplatform/certification/__init__.py"
)

text = init.read_text()

# Remove duplicate error imports
lines = text.splitlines()

seen = False
out = []

for line in lines:
    if line.startswith("from .errors import CertificationError"):
        if seen:
            continue
        seen = True
    out.append(line)

text = "\n".join(out) + "\n"

# Ensure canonical export is first import
if not text.startswith("from .errors import CertificationError"):
    text = (
        "from .errors import CertificationError\n\n"
        + text
    )

init.write_text(text)

print("patched")
PY


echo "Compile check..."

python3 -m py_compile \
builder/python/wlplatform/wlplatform/certification/__init__.py \
builder/python/wlplatform/wlplatform/certification/errors.py


echo "Running certification tests..."

python3 -m pytest \
builder/python/wlplatform/tests/test_certification_root.py \
builder/python/wlplatform/tests/test_certification.py \
-v

echo "PASS"
