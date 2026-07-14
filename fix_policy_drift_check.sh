#!/usr/bin/env bash
set -euo pipefail

ENGINE="builder/python/wlrepository/wlrepository/engine.py"

python_bin=".venv/bin/python"
if [[ ! -x "$python_bin" ]]; then
    python_bin="$(command -v python3)"
fi

"$python_bin" - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlrepository/wlrepository/engine.py"
)

text = path.read_text()

needle = '''        if tracked_ignored:
            result.add(
                "INFO",
                "TRACKED_IGNORED",
                (
                    f"{len(tracked_ignored)} tracked files match "
                    "current ignore rules; cleanup recommended"
                ),
            )
        else:
            result.add(
                "PASS",
                "TRACKED_IGNORED",
                "no tracked files match current ignore rules",
            )

        return result
'''

replacement = '''        if tracked_ignored:
            result.add(
                "INFO",
                "TRACKED_IGNORED",
                (
                    f"{len(tracked_ignored)} tracked files match "
                    "current ignore rules; cleanup recommended"
                ),
            )
        else:
            result.add(
                "PASS",
                "TRACKED_IGNORED",
                "no tracked files match current ignore rules",
            )

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

        return result
'''

if needle not in text:
    raise SystemExit(
        "verify block not found - inspect engine.py"
    )

text = text.replace(
    needle,
    replacement,
    1,
)

path.write_text(text)

print("Applied policy drift verification hook")
PY

echo
echo "Running tests..."

PYTHONPATH=builder/python/wlrepository \
"$python_bin" -m pytest builder/python/wlrepository/tests

echo
echo "Done."
