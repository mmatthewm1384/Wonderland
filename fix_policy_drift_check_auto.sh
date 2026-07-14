#!/usr/bin/env bash
set -euo pipefail

PYTHON_BIN=".venv/bin/python"
if [[ ! -x "$PYTHON_BIN" ]]; then
    PYTHON_BIN="$(command -v python3)"
fi

ENGINE="builder/python/wlrepository/wlrepository/engine.py"

"$PYTHON_BIN" - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlrepository/wlrepository/engine.py"
)

text = path.read_text()

if "POLICY_DIGEST_MISMATCH" in text:
    print("POLICY_DIGEST_MISMATCH already exists")
    raise SystemExit(0)

verify_start = text.index("    def verify(self) -> VerificationResult:")

status_start = text.index(
    "    def status(self)",
    verify_start,
)

verify_block = text[verify_start:status_start]

needle = "        return result\n"

pos = verify_block.rfind(needle)

if pos == -1:
    raise SystemExit(
        "Could not locate verify return"
    )

insert = '''
        stored_digest = self.stored_policy_digest()

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

absolute = verify_start + pos

text = (
    text[:absolute]
    + insert
    + text[absolute:]
)

path.write_text(text)

print("Inserted policy drift verification")
PY

echo "Running drift test..."

PYTHONPATH=builder/python/wlrepository \
"$PYTHON_BIN" -m pytest \
builder/python/wlrepository/tests/test_repository_engine.py::RepositoryEngineTests::test_policy_drift_detection
