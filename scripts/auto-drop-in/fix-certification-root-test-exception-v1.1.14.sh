#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

TEST="builder/python/wlplatform/tests/test_certification_root.py"

echo "Fixing invalid root certification test..."

python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/tests/test_certification_root.py"
)

text = path.read_text()

# Ensure CertificationError import exists
if "CertificationError" not in text.splitlines()[0:20]:
    text = text.replace(
        "from wlplatform.certification import certify",
        "from wlplatform.certification import certify, CertificationError"
    )

old = """    try:
        certify(root=Path("/"))

    except Exception:
        return

    raise AssertionError(
        "Expected invalid root rejection"
    )
"""

new = """    try:
        certify(root=Path("/"))

    except CertificationError:
        return

    raise AssertionError(
        "Expected CertificationError for invalid root"
    )
"""

if old in text:
    text = text.replace(old, new)
else:
    print(
        "Expected block not found; checking manually"
    )

path.write_text(text)

print("patched")
PY


echo "Compile..."

python3 -m py_compile \
builder/python/wlplatform/wlplatform/certification/__init__.py \
builder/python/wlplatform/wlplatform/certification/certifier.py


echo "Run tests..."

python3 -m pytest \
builder/python/wlplatform/tests/test_certification_root.py \
builder/python/wlplatform/tests/test_certification.py \
-v

echo "PASS"
