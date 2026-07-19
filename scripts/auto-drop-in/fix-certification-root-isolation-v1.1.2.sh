#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"
cd "$WL_ROOT"

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
BACKUP="vault/08-Operations/backups/certification-root-isolation-${STAMP}"

mkdir -p "$BACKUP"

FILES=(
"builder/python/wlplatform/wlplatform/certification/__init__.py"
"builder/python/wlplatform/wlplatform/certification/certifier.py"
"builder/python/wlplatform/wlplatform/certification/adapters/registry.py"
)

for f in "${FILES[@]}"; do
    if [[ -f "$f" ]]; then
        cp "$f" "$BACKUP/"
    fi
done

python3 <<'PY'
from pathlib import Path

# -------------------------------------------------
# Fix certification wrapper resolver
# -------------------------------------------------

path = Path(
"builder/python/wlplatform/wlplatform/certification/__init__.py"
)

text = path.read_text()

old = """
        # Explicit caller root
        if kwargs.get("root"):
            candidates.append(Path(kwargs["root"]))
"""

new = """
        # Explicit caller root is authoritative.
        if kwargs.get("root"):
            return Path(kwargs["root"]).resolve()
"""

if old not in text:
    raise SystemExit(
        "Missing explicit caller root block"
    )

text = text.replace(old,new,1)

path.write_text(text)


# -------------------------------------------------
# Fix certifier cwd fallback
# -------------------------------------------------

path = Path(
"builder/python/wlplatform/wlplatform/certification/certifier.py"
)

if path.exists():

    text = path.read_text()

    old = """
        root = Path.cwd()
"""

    new = """
        root = root.resolve()
"""

    if old in text:
        text=text.replace(old,new,1)
        path.write_text(text)


# -------------------------------------------------
# Fix registry adapter cwd
# -------------------------------------------------

path = Path(
"builder/python/wlplatform/wlplatform/certification/adapters/registry.py"
)

if path.exists():

    text = path.read_text()

    old = """
        root = Path.cwd()
"""

    new = """
        root = self.root.resolve()
"""

    if old in text:
        text=text.replace(old,new,1)
        path.write_text(text)

print("Certification root isolation patched")
PY


python3 -m py_compile \
builder/python/wlplatform/wlplatform/certification/__init__.py \
builder/python/wlplatform/wlplatform/certification/certifier.py \
builder/python/wlplatform/wlplatform/certification/adapters/registry.py


echo
echo "PASS"
echo "Backup:"
echo "$BACKUP"
