#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$WL_ROOT"

TARGET="builder/python/wlplatform/wlplatform/certification_trust.py"

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
BACKUP="vault/08-Operations/backups/certification-trust-fix-${STAMP}"

mkdir -p "$BACKUP"

cp "$TARGET" "$BACKUP/"

python3 <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/certification_trust.py"
)

text = path.read_text()

old = """
        self.output_path.write_text(
"""

new = """
        self.output_path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        self.output_path.write_text(
"""

if old not in text:
    raise SystemExit(
        "Expected trust-state write block not found"
    )

text = text.replace(old, new, 1)

path.write_text(text)

print("patched")
PY

python3 -m py_compile "$TARGET"

echo "PASS"
