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

ENGINE="builder/python/wlrepository/wlrepository/engine.py"
TEST="builder/python/wlrepository/tests/test_repository_engine.py"

echo "Applying Repository Engine 1.2 drift hardening..."

"$PYTHON_BIN" - <<'PY'
from pathlib import Path

engine = Path(
    "builder/python/wlrepository/wlrepository/engine.py"
)

text = engine.read_text()

# Add digest cache property
if "def policy_digest_path" not in text:
    marker = "    def policy_digest(self) -> str:\n"
    insert = '''    @property
    def policy_digest_path(self) -> Path:
        return self.root / ".wonderland/repository-policy.digest"

    def stored_policy_digest(self) -> str | None:
        if not self.policy_digest_path.exists():
            return None

        return self.policy_digest_path.read_text(
            encoding="utf-8"
        ).strip()

    def write_policy_digest(self) -> None:
        self.policy_digest_path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        self.policy_digest_path.write_text(
            self.policy_digest() + "\\n",
            encoding="utf-8",
        )

'''
    if marker not in text:
        raise SystemExit("policy_digest insertion point missing")

    text = text.replace(marker, insert + marker, 1)

# Add digest write after generate replace
if "self.write_policy_digest()" not in text:
    marker = "            temporary.replace(self.gitignore_path)\n"
    insert = "            self.write_policy_digest()\n"
    if marker not in text:
        raise SystemExit("generate insertion point missing")

    text = text.replace(
        marker,
        marker + insert,
        1,
    )

# Add verify drift check before return result
if "POLICY_DIGEST_MISMATCH" not in text:
    marker = "        return result\n\n    def status"
    insert = '''        stored_digest = self.stored_policy_digest()

        if stored_digest is None:
            result.add(
                "WARN",
                "POLICY_DIGEST_MISSING",
                "policy digest cache missing; run: wl repo generate",
            )
        elif stored_digest != self.policy_digest():
            result.add(
                "ERROR",
                "POLICY_DIGEST_MISMATCH",
                "repository policy changed after generation",
                str(self.policy_path.relative_to(self.root)),
            )
        else:
            result.add(
                "PASS",
                "POLICY_DIGEST",
                "repository policy digest matches",
            )

'''
    if marker not in text:
        raise SystemExit("verify insertion point missing")

    text = text.replace(
        marker,
        insert + marker,
        1,
    )

engine.write_text(text)

print("Updated engine.py")


test = Path(
    "builder/python/wlrepository/tests/test_repository_engine.py"
)

text = test.read_text()

if "test_policy_drift_detection" not in text:
    marker = "    def test_status_contains_verification_state(self) -> None:\n"

    insert = '''    def test_policy_drift_detection(self) -> None:
        self.engine.generate()

        policy = self.engine.policy_path.read_text(
            encoding="utf-8"
        )

        self.engine.policy_path.write_text(
            policy + "\\n",
            encoding="utf-8",
        )

        result = self.engine.verify()

        codes = [
            item.code
            for item in result.findings
        ]

        self.assertIn(
            "POLICY_DIGEST_MISMATCH",
            codes,
        )

'''
    if marker not in text:
        raise SystemExit("test insertion point missing")

    text = text.replace(
        marker,
        insert + marker,
        1,
    )

    test.write_text(text)
    print("Updated tests")
else:
    print("Drift test already exists")
PY

echo
echo "Running Repository Engine tests..."

PYTHONPATH=builder/python/wlrepository \
"$PYTHON_BIN" -m pytest builder/python/wlrepository/tests

echo
echo "Checking certification..."

PYTHONPATH=builder/python/wlrepository \
"$PYTHON_BIN" -m wlrepository.cli --json certify || true

echo
echo "Complete."
