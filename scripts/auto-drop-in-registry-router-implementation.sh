#!/usr/bin/env bash
set -euo pipefail

ROOT="${WONDERLAND_ROOT:-$(pwd)}"

FILE="$ROOT/builder/python/wlplatform/wlplatform/engine_router.py"

echo "======================================"
echo " Registry Router Implementation"
echo "======================================"

python3 - "$FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

text = path.read_text()

old = '''    def _registry(self, action):
        return self._result(
            "registry",
            action,
            "READY_FOR_IMPLEMENTATION",
        )
'''

new = '''    def _registry(self, action):
        from .registry_adapter import verify_registry

        if action in ("verify", "status"):
            result = verify_registry(
                self.context
            )

            return result

        return self._result(
            "registry",
            action,
            "UNSUPPORTED_ACTION",
        )
'''

if old not in text:
    raise SystemExit(
        "ERROR: registry placeholder not found"
    )

text = text.replace(old, new)

path.write_text(text)

print("Registry router implementation inserted.")
PY

echo
echo "Next verification:"
echo "  wl registry"
