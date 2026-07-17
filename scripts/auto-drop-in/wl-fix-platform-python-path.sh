#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

echo "== Wonderland Platform Python Path Repair =="

if [ ! -d "$ROOT" ]; then
    echo "FAIL: Wonderland root missing: $ROOT"
    exit 1
fi

echo "Searching for wlplatform package..."

WL_PATH="$(
python3 - <<PY
from pathlib import Path

root = Path("$ROOT")

candidates = [
    root / "builder/python",
    root / "builder/python/wlplatform",
    root / "builder/python/wlplatform/src",
]

for path in candidates:
    if (path / "wlplatform").is_dir():
        print(path)
        raise SystemExit(0)

for path in root.rglob("wlplatform"):
    if path.is_dir() and (path / "cli.py").exists():
        print(path.parent)
        raise SystemExit(0)

raise SystemExit(1)
PY
)"

if [ -z "$WL_PATH" ]; then
    echo "FAIL: Could not locate wlplatform package"
    exit 1
fi

echo "Found:"
echo "  $WL_PATH"

export PYTHONPATH="$WL_PATH:$ROOT/builder/python:${PYTHONPATH:-}"

echo
echo "Testing import..."

PYTHONPATH="$PYTHONPATH" python3 <<'PY'
import sys

print("Python import paths:")
for p in sys.path:
    if "Wonderland" in p:
        print(" ", p)

from wlplatform.cli import build_parser

parser = build_parser()

tests = [
    ["certify", "trust"],
    ["certify", "graph", "status"],
]

for command in tests:
    print()
    print("Testing:", " ".join(command))
    result = parser.parse_args(command)
    print("PASS:", result)

print()
print("Certification CLI parser verified")
PY


echo
echo "Updating launcher environment..."

LAUNCHER="$ROOT/bin/wl-platform"

if [ ! -f "$LAUNCHER" ]; then
    echo "FAIL missing launcher: $LAUNCHER"
    exit 1
fi

grep -q "builder/python" "$LAUNCHER" || {
    echo "Adding Wonderland Python path bootstrap"

    python3 <<PY
from pathlib import Path

path = Path("$LAUNCHER")
text = path.read_text()

inject = '''
# Wonderland Python bootstrap
ROOT="/Users/wonderland/Wonderland"
export PYTHONPATH="$ROOT/$("$WL_PATH" | sed "s#$ROOT/##"):$ROOT/builder/python:\${PYTHONPATH:-}"
'''

if "Wonderland Python bootstrap" not in text:
    lines = text.splitlines()
    lines.insert(1, inject.strip())
    path.write_text("\\n".join(lines) + "\\n")
PY
}

chmod +x "$LAUNCHER"

echo
echo "Verification:"
echo "  ./bin/wl-platform certify trust"
echo "  ./bin/wl-platform certify graph status"

echo
echo "DONE"
