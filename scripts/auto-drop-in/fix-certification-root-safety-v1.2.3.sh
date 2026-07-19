#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$WL_ROOT"

TARGET="builder/python/wlplatform/wlplatform/certification/certifier.py"

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
BACKUP="vault/08-Operations/backups/certification-root-safety-${STAMP}"

mkdir -p "$BACKUP"

cp "$TARGET" "$BACKUP/"

python3 <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/certification/certifier.py"
)

text = path.read_text()

if "from .errors import CertificationError" not in text:
    text = text.replace(
        "from .adapters.registry import adapters\n",
        "from .adapters.registry import adapters\nfrom .errors import CertificationError\n",
        1,
    )

old = """
    (root / "vault").mkdir(
        parents=True,
        exist_ok=True,
    )
"""

new = """
    if root == Path("/"):
        raise CertificationError(
            f"Invalid certification root: {root}"
        )

    (root / "vault").mkdir(
        parents=True,
        exist_ok=True,
    )
"""

if old not in text:
    raise SystemExit(
        "Expected vault initialization block not found"
    )

text = text.replace(old, new, 1)

path.write_text(text)

print("patched")
PY

python3 -m py_compile "$TARGET"

echo PASS
