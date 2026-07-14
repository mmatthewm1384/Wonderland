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

ENGINE_TEST="builder/python/wlrepository/tests/test_repository_engine.py"
CLI_TEST="builder/python/wlrepository/tests/test_cli.py"

echo "Adding Repository Engine 1.2 certification regression tests..."

"$PYTHON_BIN" - <<'PY'
from pathlib import Path

engine_test = Path(
    "builder/python/wlrepository/tests/test_repository_engine.py"
)

text = engine_test.read_text()

if "test_certification_returns_valid_contract" not in text:
    marker = '''
    def test_status_contains_verification_state(self) -> None:
'''
    insert = '''
    def test_certification_returns_valid_contract(self) -> None:
        self.engine.generate()

        certification = self.engine.certification()

        self.assertEqual(
            certification["engine"],
            "repository",
        )
        self.assertEqual(
            certification["version"],
            "1.2",
        )
        self.assertTrue(
            certification["certified"],
        )
        self.assertEqual(
            certification["verification"],
            "PASS",
        )
        self.assertEqual(
            certification["health_score"],
            100,
        )
        self.assertEqual(
            len(certification["policy_digest"]),
            64,
        )
        self.assertEqual(
            len(certification["generated_digest"]),
            64,
        )

'''
    if marker not in text:
        raise SystemExit(
            "Repository engine test insertion point not found"
        )

    text = text.replace(marker, insert + marker, 1)
    engine_test.write_text(text)

    print("Updated repository engine tests")
else:
    print("Repository engine certification test already exists")


cli_test = Path(
    "builder/python/wlrepository/tests/test_cli.py"
)

text = cli_test.read_text()

if "test_certify_json" not in text:
    marker = '''
    def test_unknown_command(self) -> None:
'''
    insert = '''
    def test_certify_json(self) -> None:
        with patch.dict(
            "os.environ",
            {"WL_ROOT": str(self.root)},
        ):
            rc = main(["--json", "certify"])

        self.assertEqual(rc, 0)

'''
    if marker not in text:
        raise SystemExit(
            "CLI test insertion point not found"
        )

    text = text.replace(marker, insert + marker, 1)
    cli_test.write_text(text)

    print("Updated CLI tests")
else:
    print("CLI certification test already exists")
PY

echo
echo "Running Repository Engine tests..."

PYTHONPATH=builder/python/wlrepository \
"$PYTHON_BIN" -m pytest builder/python/wlrepository/tests

echo
echo "Testing certification..."

PYTHONPATH=builder/python/wlrepository \
"$PYTHON_BIN" -m wlrepository.cli --json certify

echo
echo "Complete."
