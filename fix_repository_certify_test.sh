#!/usr/bin/env bash
set -euo pipefail

if [[ -x ".venv/bin/python" ]]; then
    PYTHON_BIN=".venv/bin/python"
elif command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="$(command -v python3)"
else
    echo "FAIL: Python interpreter not found"
    exit 1
fi

TEST_FILE="builder/python/wlrepository/tests/test_cli.py"

echo "Fixing certification CLI test fixture..."

"$PYTHON_BIN" - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlrepository/tests/test_cli.py"
)

text = path.read_text()

old = '''    def test_certify_json(self) -> None:
        with patch.dict(
            "os.environ",
            {"WL_ROOT": str(self.root)},
        ):
            rc = main(["--json", "certify"])

        self.assertEqual(rc, 0)
'''

new = '''    def test_certify_json(self) -> None:
        from wlrepository.engine import RepositoryEngine

        engine = RepositoryEngine(self.root)
        engine.generate()

        with patch.dict(
            "os.environ",
            {"WL_ROOT": str(self.root)},
        ):
            rc = main(["--json", "certify"])

        self.assertEqual(rc, 0)
'''

if old not in text:
    raise SystemExit(
        "certify_json test block not found"
    )

text = text.replace(old, new, 1)

path.write_text(text)

print("Updated", path)
PY

echo
echo "Running tests..."

PYTHONPATH=builder/python/wlrepository \
"$PYTHON_BIN" -m pytest builder/python/wlrepository/tests

echo
echo "Complete."
