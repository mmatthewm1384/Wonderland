#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/targets/loader.py"

cp "$TARGET" "$TARGET.certification-resolution-backup"

python3 - "$TARGET" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

text = path.read_text()

needle = "    def get(self, name):"

insert = '''
    def certified(self, name):

        target = self.get(name)

        cert = target.get(
            "certification",
            {}
        )

        if cert.get("required") is not True:
            return True

        artifact = cert.get(
            "package"
        )

        if artifact:
            return True

        return False


'''

if "def certified(" not in text:
    text=text.replace(
        needle,
        insert+needle
    )

path.write_text(text)
PY

python3 -m compileall "$TARGET"

echo "installed"
