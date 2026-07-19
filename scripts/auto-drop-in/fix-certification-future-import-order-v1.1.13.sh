#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

FILE="builder/python/wlplatform/wlplatform/certification.py"

echo "Fixing certification import order..."

python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/certification.py"
)

text = path.read_text()

bad = "from .certification.errors import CertificationError\n\n"

# Remove misplaced import
text = text.replace(bad, "")

lines = text.splitlines()

# Find last future import
future_index = -1

for i, line in enumerate(lines):
    if line.startswith("from __future__ import"):
        future_index = i

if future_index == -1:
    raise SystemExit(
        "No future import found"
    )

# Insert after future imports
insert_at = future_index + 1

while (
    insert_at < len(lines)
    and lines[insert_at].strip() == ""
):
    insert_at += 1

lines.insert(
    insert_at,
    "from .certification.errors import CertificationError"
)

path.write_text(
    "\n".join(lines) + "\n"
)

print("patched")
PY


echo "Compile verification..."

python3 -m py_compile \
builder/python/wlplatform/wlplatform/certification.py \
builder/python/wlplatform/wlplatform/certification/__init__.py \
builder/python/wlplatform/wlplatform/certification/errors.py


echo "Exception identity verification..."

python3 - <<'PY'
from wlplatform.certification import CertificationError as A
from wlplatform.certification.errors import CertificationError as B

assert A is B

print("CertificationError identity PASS")
PY


echo "Run certification tests..."

python3 -m pytest \
builder/python/wlplatform/tests/test_certification_root.py \
builder/python/wlplatform/tests/test_certification.py \
-v

echo "PASS"
