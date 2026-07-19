#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$WL_ROOT"

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
BACKUP="vault/08-Operations/backups/certification-runtime-path-${STAMP}"

mkdir -p "$BACKUP"

echo "== Certification Runtime Path Fix =="


# -------------------------------------------------
# Backup
# -------------------------------------------------

find builder/python/wlplatform/wlplatform \
    -path "*certification*" \
    -name "*.py" \
    -exec cp --parents {} "$BACKUP" \; || true


# -------------------------------------------------
# Force local source precedence
# -------------------------------------------------

export PYTHONPATH="$WL_ROOT/builder/python/wlplatform:$WL_ROOT/builder/python:${PYTHONPATH:-}"

echo "PYTHONPATH:"
echo "$PYTHONPATH"


# -------------------------------------------------
# Patch active certification code
# -------------------------------------------------

python3 <<'PY'
from pathlib import Path
import re

root = Path(
    "builder/python/wlplatform/wlplatform"
)


# Fix unsafe root resolve
for path in root.rglob("*.py"):

    text = path.read_text()
    original = text

    text = text.replace(
        "root = root.resolve()",
        """
if root is None:
    raise CertificationError(
        "Certification root required"
    )

root = Path(root).resolve()
"""
    )

    if text != original:
        path.write_text(text)
        print("patched root:", path)


# Fix trust-state writes
for path in root.rglob("*.py"):

    text = path.read_text()

    if "trust-state.json" not in text:
        continue

    if "mkdir(" in text and "parents=True" in text:
        continue

    text = re.sub(
        r"(trust_state\s*=.*)",
        r"""
\1

        trust_state.parent.mkdir(
            parents=True,
            exist_ok=True,
        )
""",
        text,
        count=1,
    )

    path.write_text(text)
    print("patched trust writer:", path)

PY


# -------------------------------------------------
# Verify import target
# -------------------------------------------------

echo
echo "== Import Verification =="

PYTHONPATH="$WL_ROOT/builder/python/wlplatform:$WL_ROOT/builder/python" \
python3 - <<'PY'
import wlplatform
print(wlplatform.__file__)
PY


echo
echo "== Syntax =="

python3 -m compileall \
builder/python/wlplatform/wlplatform/certification \
builder/python/wlplatform/wlplatform/certification_trust.py


echo
echo "PASS"
echo "Backup:"
echo "$BACKUP"
