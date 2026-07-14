#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

ENGINE="builder/python/wlrepository/wlrepository/engine.py"

echo "Applying Repository Engine tracked-ignored severity change..."

python3 - <<'PY'
from pathlib import Path

path = Path("builder/python/wlrepository/wlrepository/engine.py")

text = path.read_text()

old = '''            result.add(
                "WARN",
                "TRACKED_IGNORED",
                (
                    f"{len(tracked_ignored)} tracked files match "
                    "current ignore rules"
                ),
            )
'''

new = '''            result.add(
                "INFO",
                "TRACKED_IGNORED",
                (
                    f"{len(tracked_ignored)} tracked files match "
                    "current ignore rules; cleanup recommended"
                ),
            )
'''

if old not in text:
    raise SystemExit(
        "Expected TRACKED_IGNORED block not found"
    )

text = text.replace(old, new, 1)

path.write_text(text)

print("Updated:", path)
PY

echo
echo "Running Repository Engine tests..."

PYTHONPATH=builder/python/wlrepository \
python -m pytest builder/python/wlrepository/tests

echo
echo "Checking health..."

PYTHONPATH=builder/python/wlrepository \
python -m wlrepository.cli --json health

echo
echo "Complete."
