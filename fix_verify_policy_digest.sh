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

start = text.index(
    "    def verify(self) -> VerificationResult:"
)

end = text.index(
    "    def status",
    start,
)

verify = text[start:end]

if "POLICY_DIGEST_MISMATCH" in verify:
    print("verify already patched")
    raise SystemExit(0)

marker = "\n        return result"

position = verify.rfind(marker)

if position == -1:
    raise SystemExit(
        "Could not locate verify() return result"
    )

insert = r'''

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

absolute = start + position

text = (
    text[:absolute]
    + insert
    + text[absolute:]
)

path.write_text(text)

print("verify() patched")
PY

echo
grep -n "POLICY_DIGEST" "$ENGINE"

echo
echo "Running drift regression..."

PYTHONPATH=builder/python/wlrepository \
"$PYTHON_BIN" -m pytest \
builder/python/wlrepository/tests/test_repository_engine.py::RepositoryEngineTests::test_policy_drift_detection
