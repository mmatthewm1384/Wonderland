#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"
cd "$WL_ROOT"

TARGET="builder/python/wlplatform/wlplatform/certification/__init__.py"

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
BACKUP="vault/08-Operations/backups/certification-keyword-root-${STAMP}"

mkdir -p "$BACKUP"
cp "$TARGET" "$BACKUP/"

python3 <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/certification/__init__.py"
)

text = path.read_text()

old = """
    return _engine_certify(
        root,
        include_optional=include_optional,
    )
"""

new = """
    return _engine_certify(
        root=root,
        include_optional=include_optional,
    )
"""

if old not in text:
    raise SystemExit(
        "Expected _engine_certify call not found"
    )

text = text.replace(old, new, 1)

path.write_text(text)

print("patched")
PY

python3 -m py_compile "$TARGET"

echo PASS
