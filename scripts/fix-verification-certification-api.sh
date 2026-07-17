#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

FILE="builder/python/wlplatform/wlplatform/verification.py"

cp "$FILE" "$FILE.backup.$(date +%Y%m%d-%H%M%S)"

python3 - <<'PY'
from pathlib import Path

p = Path(
"builder/python/wlplatform/wlplatform/verification.py"
)

text = p.read_text()

text = text.replace(
"from .certification import (\n    PlatformCertificationEngine,\n)",
"from .certification import certify"
)

text = text.replace(
"""
graph = (
            PlatformCertificationEngine(
                self.root
            )
            .graph()
        )
""",
"""
certification = certify(
            self.root
        )

        graph = certification.get(
            "engines",
            {}
        )
"""
)

p.write_text(text)

print("verification API migrated")
PY
