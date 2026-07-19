#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$WL_ROOT"

TARGET="builder/python/wlplatform/wlplatform/engine.py"

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
BACKUP_DIR="vault/08-Operations/backups/engine-root-fix-${STAMP}"

mkdir -p "$BACKUP_DIR"

echo "== Platform Certification Engine Root Fix =="

if [[ ! -f "$TARGET" ]]; then
    echo "ERROR: Missing:"
    echo "$TARGET"
    exit 1
fi

cp "$TARGET" "$BACKUP_DIR/"

echo "Backup:"
echo "$BACKUP_DIR"


python3 <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/engine.py"
)

text = path.read_text()

old = """    def __init__(self, root: Path):
        self.root = root.resolve()
"""

new = """    def __init__(self, root: Path):
        if root is None:
            raise ValueError(
                "Certification root required"
            )

        self.root = Path(root).resolve()
"""

if old not in text:
    raise SystemExit(
        "Expected PlatformCertificationEngine root initializer not found"
    )

text = text.replace(old, new, 1)

path.write_text(text)

print("Patched:", path)
PY


echo
echo "== Syntax Verification =="

python3 -m py_compile "$TARGET"

echo
echo "PASS"
echo "Backup:"
echo "$BACKUP_DIR"
