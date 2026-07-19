#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"
cd "$WL_ROOT"

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
BACKUP="vault/08-Operations/backups/certification-active-repair-${STAMP}"

mkdir -p "$BACKUP"

echo "== Backup =="

find builder/python/wlplatform/wlplatform \
    -path "*certification*" \
    -name "*.py" \
    -exec cp --parents {} "$BACKUP" \;

echo "Backup: $BACKUP"


python3 <<'PY'
from pathlib import Path
import re


ROOT = Path(
    "builder/python/wlplatform/wlplatform"
)


# -------------------------------------------------
# Fix every unsafe root.resolve()
# -------------------------------------------------

for path in ROOT.rglob("*.py"):

    text = path.read_text()

    if ".resolve()" in text and "root" in text:

        original = text

        text = re.sub(
            r"^\s*root\s*=\s*root\.resolve\(\)",
            """
        if root is None:
            raise CertificationError(
                "Certification root required"
            )

        root = Path(root).resolve()
""",
            text,
            flags=re.MULTILINE,
        )

        if text != original:
            path.write_text(text)
            print("patched root:", path)


# -------------------------------------------------
# Fix trust-state writer
# -------------------------------------------------

for path in ROOT.rglob("*.py"):

    text = path.read_text()

    if "trust-state.json" not in text:
        continue

    print("trust writer:", path)

    if "trust_state.parent.mkdir" not in text:

        text = re.sub(
            r"(trust_state\s*=.*?\n)",
            r"""\1
        trust_state.parent.mkdir(
            parents=True,
            exist_ok=True,
        )
""",
            text,
            count=1,
            flags=re.MULTILINE,
        )

        path.write_text(text)
        print("patched trust:", path)


print("complete")
PY


echo
echo "== Compile =="

python3 -m compileall \
builder/python/wlplatform/wlplatform/certification \
builder/python/wlplatform/wlplatform/certification_trust.py


echo
echo "PASS"
