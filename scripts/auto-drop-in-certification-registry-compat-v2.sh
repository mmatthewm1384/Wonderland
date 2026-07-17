#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

echo "== Certification Registry Compatibility v2 =="

FILE="builder/python/wlplatform/wlplatform/certification_registry.py"

python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/certification_registry.py"
)

text = path.read_text()

if "def normalize_active" not in text:

    print("Adding normalize_active compatibility")

    insert = """

    def normalize_active(self):

        discovered = self.discover()

        return dict(
            sorted(
                discovered.items()
            )
        )


"""

    marker = "    def load(self):"

    if marker not in text:
        raise SystemExit(
            "Cannot locate load()"
        )

    text = text.replace(
        marker,
        insert + marker
    )


if "def active(self)" not in text:

    print("Adding active compatibility")

    insert = """

    def active(self):

        return self.normalize_active()


"""

    marker = "    def load(self):"

    text = text.replace(
        marker,
        insert + marker
    )


path.write_text(text)

print("patched")
PY


echo "Clearing python cache..."

find builder/python/wlplatform \
-name "__pycache__" \
-type d \
-exec rm -rf {} +


echo "Testing..."

PYTHONPATH="$ROOT/builder/python/wlplatform" python3 - <<'PY'
from wlplatform.certification_registry import CertificationRegistry

print(
    hasattr(
        CertificationRegistry,
        "normalize_active"
    )
)

print(
    hasattr(
        CertificationRegistry,
        "active"
    )
)
PY
