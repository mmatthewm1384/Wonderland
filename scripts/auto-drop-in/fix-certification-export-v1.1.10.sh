#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

INIT="builder/python/wlplatform/wlplatform/certification/__init__.py"

echo "Patching certification export boundary..."

python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/certification/__init__.py"
)

text = path.read_text()

# Ensure CertificationError import exists
if "from .errors import CertificationError" not in text:
    text = (
        "from .errors import CertificationError\n\n"
        + text
    )

# Add PlatformCertificationEngine export
if "PlatformCertificationEngine" not in text:
    marker = "from .certifier import (\n    certify as _engine_certify,\n)\n"

    if marker not in text:
        raise SystemExit(
            "Unable to locate certifier import block"
        )

    text = text.replace(
        marker,
        marker
        + "\n\n"
        + "from ..engine import PlatformCertificationEngine\n"
    )

# Normalize certify function ending
old = """    return _engine_certify(
        root=root,
        include_optional=include_optional,
    )
"""

new = """    return _engine_certify(
        root=root,
        include_optional=include_optional,
    )
"""

if old not in text:
    raise SystemExit(
        "Expected certify boundary not found"
    )

text = text.replace(old, new)

path.write_text(text)

print("patched")
PY


echo "Running syntax verification..."

python3 -m py_compile \
builder/python/wlplatform/wlplatform/certification/__init__.py


echo "Running certification tests..."

python3 -m pytest \
builder/python/wlplatform/tests/test_certification_root.py \
builder/python/wlplatform/tests/test_certification.py \
-v

echo "PASS"
