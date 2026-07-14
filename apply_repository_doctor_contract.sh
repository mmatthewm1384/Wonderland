#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

ENGINE="builder/python/wlrepository/wlrepository/engine.py"

echo "Applying Repository Doctor contract..."

python3 <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlrepository/wlrepository/engine.py"
)

text = path.read_text()

old = '''        return {
            "engine": "repository",
            "status": (
                "PASS"
                if (
                    verification.passed
                    and certificate.get("valid", False)
                )
                else "FAIL"
            ),
            "verification": verification.as_dict(),
            "certificate": certificate,
            "health": self.health(),
        }
'''

new = '''        return {
            "schema_version": 1,
            "engine": "repository",
            "version": "1.2.2",
            "status": (
                "PASS"
                if (
                    verification.passed
                    and certificate.get("valid", False)
                )
                else "FAIL"
            ),
            "verification": verification.as_dict(),
            "certificate": certificate,
            "health": self.health(),
        }
'''

if old not in text:
    if '"schema_version": 1' not in text:
        raise SystemExit(
            "doctor contract block not found"
        )
else:
    text = text.replace(old, new)

path.write_text(text)

PY

echo
echo "Running tests..."

PYTHONPATH=builder/python/wlrepository \
python -m pytest builder/python/wlrepository/tests

echo
echo "Doctor contract output..."

PYTHONPATH=builder/python/wlrepository \
python -m wlrepository.cli --json doctor

echo
echo "Repository Doctor contract applied."
