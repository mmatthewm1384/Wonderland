#!/usr/bin/env bash
set -euo pipefail

PYTHON_BIN=".venv/bin/python"
[[ -x "$PYTHON_BIN" ]] || PYTHON_BIN="$(command -v python3)"

ENGINE="builder/python/wlrepository/wlrepository/engine.py"

"$PYTHON_BIN" - <<'PY'
from pathlib import Path

p = Path(
    "builder/python/wlrepository/wlrepository/engine.py"
)

text = p.read_text()

if "POLICY_DIGEST_MISMATCH" in text:
    print("Drift check already present")
    raise SystemExit(0)

start = text.index(
    "    def verify(self) -> VerificationResult:"
)

end = text.index(
    "    def status(self)",
    start,
)

verify = text[start:end]

target = "\n        return result\n"

idx = verify.rfind(target)

if idx < 0:
    raise SystemExit(
        "Unable to locate verify() return"
    )

block = '''
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

absolute = start + idx

text = text[:absolute] + block + text[absolute:]

p.write_text(text)

print("Inserted drift verification into verify()")
PY

PYTHONPATH=builder/python/wlrepository \
"$PYTHON_BIN" -m pytest \
builder/python/wlrepository/tests/test_repository_engine.py::RepositoryEngineTests::test_policy_drift_detection
