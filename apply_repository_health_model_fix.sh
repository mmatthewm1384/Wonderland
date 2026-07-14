#!/usr/bin/env bash
set -euo pipefail

PYTHON_BIN=""

if [[ -x ".venv/bin/python" ]]; then
    PYTHON_BIN=".venv/bin/python"
elif command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="$(command -v python3)"
else
    echo "FAIL: Python interpreter not found"
    exit 1
fi

ENGINE="builder/python/wlrepository/wlrepository/engine.py"

echo "Applying Repository Engine health model fix..."

"$PYTHON_BIN" - <<'PY'
from pathlib import Path

path = Path("builder/python/wlrepository/wlrepository/engine.py")

text = path.read_text()

old = '''            result.add(
                "INFO",
                "TRACKED_IGNORED",
                (
                    f"{len(tracked_ignored)} tracked files match "
                    "current ignore rules; cleanup recommended"
                ),
            )
'''

new = '''            result.add(
                "WARN",
                "TRACKED_IGNORED",
                (
                    f"{len(tracked_ignored)} tracked files match "
                    "current ignore rules; cleanup recommended"
                ),
            )
'''

if old not in text:
    raise SystemExit("TRACKED_IGNORED INFO block not found")

text = text.replace(old, new, 1)

old_health = '''    def health(self) -> dict[str, Any]:
        verification = self.verify()

        score = 100
        score -= verification.errors * 25
        score -= verification.warnings * 5
        score = max(score, 0)

        return {
            "score": score,
            "result": "PASS" if verification.passed else "FAIL",
            "errors": verification.errors,
            "warnings": verification.warnings,
        }
'''

new_health = '''    def health(self) -> dict[str, Any]:
        verification = self.verify()

        score = 100
        score -= verification.errors * 25
        score = max(score, 0)

        return {
            "score": score,
            "result": "PASS" if verification.errors == 0 else "FAIL",
            "errors": verification.errors,
            "warnings": verification.warnings,
        }
'''

if old_health not in text:
    raise SystemExit("health block not found")

text = text.replace(old_health, new_health, 1)

path.write_text(text)

print(f"Updated {path}")
PY

echo
echo "Running tests..."

PYTHONPATH=builder/python/wlrepository \
"$PYTHON_BIN" -m pytest builder/python/wlrepository/tests

echo
echo "Checking health..."

PYTHONPATH=builder/python/wlrepository \
"$PYTHON_BIN" -m wlrepository.cli --json health

echo
echo "Complete."
