#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"
cd "$WL_ROOT"

TARGET="builder/python/wlplatform/wlplatform/certification/__init__.py"

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
BACKUP="vault/08-Operations/backups/certification-root-fix-safe-${STAMP}"

mkdir -p "$BACKUP"

cp "$TARGET" "$BACKUP/"

python3 <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/certification/__init__.py"
)

text = path.read_text()

needle = "def resolve_root"

pos = text.find(needle)

if pos == -1:
    raise SystemExit("resolve_root not found")

start = text.find("\n", pos)

if start == -1:
    raise SystemExit("function signature malformed")


insert = """

    # Explicit root override is authoritative.
    if kwargs.get("root"):
        return Path(kwargs["root"]).resolve()

"""

after_signature = start + 1

if "Explicit root override is authoritative" in text:
    print("Already patched")
    raise SystemExit(0)

text = (
    text[:after_signature]
    + insert
    + text[after_signature:]
)

path.write_text(text)

print("Patched:", path)
PY


python3 -m py_compile "$TARGET"

echo "PASS"
echo "Backup:"
echo "$BACKUP"
