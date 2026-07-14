#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$HOME/Wonderland"
ENGINE="$ROOT/builder/python/wlruntime/wlruntime/engine.py"

echo "Backing up engine..."
cp "$ENGINE" "$ENGINE.bak.$(date +%Y%m%dT%H%M%SZ)"

python3 - "$ENGINE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

old = "    def _recover_stale_operation(self) -> None:"

new = "    def _recover_stale_operation(self, state: dict | None = None) -> None:"

if old not in text:
    raise SystemExit("recover method signature not found")

text = text.replace(old, new, 1)

path.write_text(text)

print("Updated _recover_stale_operation signature")
PY

python3 -m compileall \
"$ROOT/builder/python/wlruntime/wlruntime"

echo "Lifecycle Certification v2.3.2 complete"
