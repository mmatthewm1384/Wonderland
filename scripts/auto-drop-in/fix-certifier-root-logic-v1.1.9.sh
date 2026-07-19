#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"
cd "$WL_ROOT"

TARGET="builder/python/wlplatform/wlplatform/certification/certifier.py"

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
BACKUP="vault/08-Operations/backups/certifier-root-logic-${STAMP}"

mkdir -p "$BACKUP"
cp "$TARGET" "$BACKUP/"

python3 <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/certification/certifier.py"
)

text = path.read_text()

old = """
    if root is None:

        if root is None:
            raise CertificationError(
                "Certification root required"
            )

        root = Path(root).resolve()


    root = Path(root).expanduser().resolve()
"""

new = """
    root = Path(root).expanduser().resolve()
"""

if old not in text:
    raise SystemExit(
        "Expected broken root block not found"
    )

text = text.replace(old, new, 1)

path.write_text(text)

print("patched")
PY

python3 -m py_compile "$TARGET"

echo "PASS"
