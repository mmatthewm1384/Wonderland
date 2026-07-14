#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${WL_ROOT:-$HOME/Wonderland}"
FILE="$ROOT/builder/python/wlruntime/wlruntime/engine.py"

cp "$FILE" "$FILE.bak.$(date +%Y%m%d%H%M%S)"

python3 - <<'PY'
from pathlib import Path

path = Path("builder/python/wlruntime/wlruntime/engine.py")

text = path.read_text()

old = "def _recover_stale_operation(self, state: dict | None = None) -> None:"

new = "def _recover_stale_operation(self, state: dict | None = None) -> dict:"

if old in text:
    text = text.replace(old, new, 1)
else:
    print("signature already patched or missing")

# Add return before next method if missing
marker = "\n    def __init__("

start = text.find("    def _recover_stale_operation")
end = text.find(marker, start)

if start == -1 or end == -1:
    raise SystemExit("recover method boundaries not found")

section = text[start:end]

if "return state" not in section:
    section = section.rstrip() + "\n\n        return state\n"
    text = text[:start] + section + text[end:]
    print("added return state")
else:
    print("return state already exists")

path.write_text(text)
PY

python3 -m compileall \
"$ROOT/builder/python/wlruntime/wlruntime"

echo "recover return patch complete"
