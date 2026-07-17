#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE="$ROOT/builder/python/wlplatform/wlplatform/verification.py"

echo "Target:"
echo "$FILE"

cp "$FILE" "$FILE.backup.$(date +%Y%m%d-%H%M%S)"

python3 - "$FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

text = path.read_text()

old_imports = [
    "from .certification import CertificationEngine",
    "from .certification import (\n    CertificationEngine,\n)",
    "from .certification import (\n        CertificationEngine,\n    )",
]

for old in old_imports:
    text = text.replace(
        old,
        "from .certification_state import CertificationState",
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

print("patched")
PY

echo
echo "Checking import..."
PYTHONPATH="$ROOT/builder/python/wlplatform" \
python3 - <<'PY'
from wlplatform.verification import PlatformVerificationEngine
print("verification import PASS")
PY

grep -n "CertificationEngine\|CertificationState" \
"$FILE" || true
