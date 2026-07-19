#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

TEST="builder/python/wlplatform/tests/test_certification_root.py"

echo "Patching certification root test exception handling..."

python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/tests/test_certification_root.py"
)

text = path.read_text()

# Ensure canonical exception import
if "CertificationError" not in text:
    text = text.replace(
        "from wlplatform.certification import certify",
        "from wlplatform.certification import certify, CertificationError"
    )

# Replace broad/incorrect handler
text = text.replace(
    "except Exception:",
    "except CertificationError:"
)

text = text.replace(
    "except RuntimeError:",
    "except CertificationError:"
)

path.write_text(text)

print("patched")
PY


echo "Compile verification..."

python3 -m py_compile \
builder/python/wlplatform/wlplatform/certification/certifier.py \
builder/python/wlplatform/wlplatform/certification/__init__.py


echo "Running certification tests..."

python3 -m pytest \
builder/python/wlplatform/tests/test_certification_root.py \
builder/python/wlplatform/tests/test_certification.py \
-v

echo "PASS"
