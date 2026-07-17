#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE="$ROOT/builder/python/wlplatform/wlplatform/verification.py"

echo "Patching:"
echo "$FILE"

cp "$FILE" "$FILE.backup.$(date +%Y%m%d-%H%M%S)"

python3 - "$FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

text = text.replace(
    "from .certification import (\n    CertificationEngine,\n)",
    "from .certification_state import CertificationState,\n",
)

text = text.replace(
"""        graph = (
            CertificationEngine(
                self.root
            )
            .graph()
        )
""",
"""        state = CertificationState(
            self.root
        ).collect()

        graph = state.get(
            "engines",
            {}
        )

        graph = {
            name: value
            for name, value in graph.items()
            if isinstance(value, dict)
        }
"""
)

path.write_text(text)

print("patched:", path)
PY

echo
echo "Verification import test:"
PYTHONPATH="$ROOT/builder/python/wlplatform" \
python3 - <<'PY'
from wlplatform.verification import PlatformVerificationEngine
print("verification import: PASS")
PY

echo
echo "Running regression test:"
PYTHONPATH="$ROOT/builder/python/wlplatform" \
python3 -m pytest \
"$ROOT/builder/python/wlplatform/wlplatform/tests/test_certification_regression.py"
