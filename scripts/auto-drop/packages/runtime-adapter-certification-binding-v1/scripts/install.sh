#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters/lima_adapter.py"

BACKUP="${TARGET}.runtime-adapter-certification-binding-v1.bak"

cp "$TARGET" "$BACKUP"

restore() {
    cp "$BACKUP" "$TARGET"
}

trap restore ERR


python3 <<PY
from pathlib import Path

p = Path("$TARGET")

text = p.read_text()


if "RuntimeCertificationResolver" not in text:

    text = text.replace(
        "from pathlib import Path",
        """from pathlib import Path

from wlplatform.runtime.certification.resolver import (
    RuntimeCertificationResolver
)
"""
    )


old = '"certified": False'

if old in text:

    new = '''"certified":
                RuntimeCertificationResolver(
                    self.root
                ).resolve(
                    self.instance
                )'''

    text = text.replace(
        old,
        new
    )

else:
    print(
        "No static certification field found"
    )


p.write_text(text)

PY


python3 -m compileall "$TARGET"

rm -f "$BACKUP"

echo "Certification binding installed"

