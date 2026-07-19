#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$WL_ROOT"

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
BACKUP_DIR="vault/08-Operations/backups/certification-root-artifacts-${STAMP}"

mkdir -p "$BACKUP_DIR"

echo "== Certification Root + Artifact Fix =="
echo "Backup: $BACKUP_DIR"

FILES=(
"builder/python/wlplatform/wlplatform/certification/certifier.py"
"builder/python/wlplatform/wlplatform/certification_trust.py"
)

for FILE in "${FILES[@]}"; do
    if [[ -f "$FILE" ]]; then
        cp "$FILE" "$BACKUP_DIR/"
        echo "Backed up $FILE"
    fi
done


python3 <<'PY'
from pathlib import Path


def patch_file(path: Path, replacements):
    if not path.exists():
        print(f"SKIP {path}")
        return

    text = path.read_text()

    original = text

    for old, new in replacements:
        if old in text:
            text = text.replace(old, new, 1)
            print(f"PATCH {path}: {old.strip()[:60]}")
        else:
            print(f"MISS {path}: {old.strip()[:60]}")

    if text != original:
        path.write_text(text)


# -------------------------------------------------
# Fix certifier root ownership
# -------------------------------------------------

patch_file(
    Path(
        "builder/python/wlplatform/wlplatform/"
        "certification/certifier.py"
    ),
    [
        (
            "root = Path.cwd()\n",
            """\
if root is None:
    raise CertificationError(
        "Certification root required"
    )

root = Path(root).resolve()
"""
        )
    ],
)


# -------------------------------------------------
# Fix trust artifact directory creation
# -------------------------------------------------

patch_file(
    Path(
        "builder/python/wlplatform/wlplatform/"
        "certification_trust.py"
    ),
    [
        (
            'trust_state.write_text(',
            """\
trust_state.parent.mkdir(
    parents=True,
    exist_ok=True,
)

trust_state.write_text("""
        )
    ],
)


print("Patch phase complete")
PY


echo
echo "== Syntax Verification =="

python3 -m py_compile \
builder/python/wlplatform/wlplatform/certification/certifier.py \
builder/python/wlplatform/wlplatform/certification_trust.py


echo
echo "PASS"
echo "Backup:"
echo "$BACKUP_DIR"
