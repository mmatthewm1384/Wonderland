#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$WL_ROOT"

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
BACKUP="vault/08-Operations/backups/certification-contract-${STAMP}"

mkdir -p "$BACKUP"

echo "== Certification Contract Fix =="


FILES=(
"builder/python/wlplatform/wlplatform/certification/certifier.py"
"builder/python/wlplatform/wlplatform/certification_trust.py"
"builder/python/wlplatform/wlplatform/certification/__init__.py"
)

for f in "${FILES[@]}"; do
    if [[ -f "$f" ]]; then
        cp "$f" "$BACKUP/"
    fi
done


python3 <<'PY'
from pathlib import Path


# -------------------------------------------------
# certifier.py import + root validation
# -------------------------------------------------

path = Path(
"builder/python/wlplatform/wlplatform/certification/certifier.py"
)

if path.exists():

    text = path.read_text()

    if "CertificationError" in text and \
       "from .errors import CertificationError" not in text:

        text = (
            "from .errors import CertificationError\n"
            + text
        )

    text = text.replace(
        "root = Path(root).resolve()",
        """
if root is None:
    raise CertificationError(
        "Certification root required"
    )

root = Path(root).resolve()
"""
    )

    path.write_text(text)


# -------------------------------------------------
# trust-state artifact creation
# -------------------------------------------------

path = Path(
"builder/python/wlplatform/wlplatform/certification_trust.py"
)

if path.exists():

    text = path.read_text()

    marker = "trust_state.write_text"

    if marker in text and "trust_state.parent.mkdir" not in text:

        text = text.replace(
            marker,
            """
trust_state.parent.mkdir(
    parents=True,
    exist_ok=True,
)

trust_state.write_text
""",
            1
        )

        path.write_text(text)


# -------------------------------------------------
# Controller root diagnostics
# -------------------------------------------------

path = Path(
"builder/python/wlplatform/wlplatform/certification/__init__.py"
)

if path.exists():

    text = path.read_text()

    old = """
        if root is None:
            raise CertificationError(
                "Controller has no certification root"
            )
"""

    new = """
        if root is None:
            root = getattr(controller, "root_dir", None)

        if root is None:
            raise CertificationError(
                "Controller has no certification root"
            )
"""

    if old in text:
        text = text.replace(old, new, 1)
        path.write_text(text)


print("Certification contract patch complete")
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
