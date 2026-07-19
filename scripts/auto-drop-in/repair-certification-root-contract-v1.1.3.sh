#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$WL_ROOT"

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
BACKUP="vault/08-Operations/backups/certification-contract-${STAMP}"

mkdir -p "$BACKUP"

echo "Backup: $BACKUP"

cp \
builder/python/wlplatform/wlplatform/certification/*.py \
"$BACKUP/" 2>/dev/null || true

cp \
builder/python/wlplatform/wlplatform/certification_trust.py \
"$BACKUP/" 2>/dev/null || true


python3 <<'PY'
from pathlib import Path
import re


ROOT = Path(
    "builder/python/wlplatform/wlplatform"
)


# -------------------------------------------------
# Locate every cwd-based root assumption
# -------------------------------------------------

for path in ROOT.rglob("*.py"):

    text = path.read_text()

    if "Path.cwd()" in text:

        print("FOUND cwd:", path)

        text = text.replace(
            "Path.cwd()",
            "Path(root).resolve() if root else Path.cwd()"
        )

        path.write_text(text)

        print("PATCHED:", path)


# -------------------------------------------------
# Locate trust-state writers
# -------------------------------------------------

for path in ROOT.rglob("*.py"):

    text = path.read_text()

    if "trust-state.json" in text:

        print("FOUND trust writer:", path)

        # inject mkdir immediately before write_text/open
        text = re.sub(
            r"(trust_state\s*=\s*[^\\n]+)",
            r"\1\n\n        trust_state.parent.mkdir(parents=True, exist_ok=True)",
            text,
            count=1,
        )

        path.write_text(text)

        print("PATCHED:", path)


print("Done")
PY


echo
echo "== Compile =="

python3 -m compileall \
builder/python/wlplatform/wlplatform/certification \
builder/python/wlplatform/wlplatform/certification_trust.py


echo
echo "PASS"
echo "Backup:"
echo "$BACKUP"
