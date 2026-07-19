#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

LEGACY="builder/python/wlplatform/wlplatform/certification.py"

echo "Fixing CertificationError single source..."

python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/certification.py"
)

text = path.read_text()

old = """class CertificationError(Exception):
    pass
"""

if old in text:
    text = text.replace(
        old,
        """from .certification.errors import CertificationError
"""
    )
else:
    print("Legacy class not found; checking existing import")

if "from .certification.errors import CertificationError" not in text:
    text = (
        "from .certification.errors import CertificationError\n\n"
        + text
    )

path.write_text(text)

print("patched")
PY


echo "Compile..."

python3 -m py_compile \
builder/python/wlplatform/wlplatform/certification.py \
builder/python/wlplatform/wlplatform/certification/__init__.py \
builder/python/wlplatform/wlplatform/certification/errors.py


echo "Verify exception identity..."

python3 - <<'PY'
from wlplatform.certification import CertificationError as A
from wlplatform.certification.errors import CertificationError as B

assert A is B, (
    f"Mismatch: {A} != {B}"
)

print("CertificationError identity PASS")
PY


echo "Run tests..."

python3 -m pytest \
builder/python/wlplatform/tests/test_certification_root.py \
builder/python/wlplatform/tests/test_certification.py \
-v

echo "PASS"
