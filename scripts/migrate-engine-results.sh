#!/usr/bin/env bash
set -euo pipefail

ROOT="builder/python/wlplatform/wlplatform/engines"

backup() {
    local file="$1"
    cp "$file" "${file}.backup.$(date +%Y%m%d-%H%M%S)"
}

patch_engine() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "SKIP missing: $file"
        return
    fi

    backup "$file"

    python3 - "$file" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

text = path.read_text()

# Replace result imports
text = text.replace(
    "from ..result import CheckResult, Status",
    "from ..engine_contract import EngineContract, EngineResult"
)

# Ensure EngineResult import exists
if "EngineResult" not in text:
    text = text.replace(
        "from __future__ import annotations",
        "from __future__ import annotations\n\n"
        "from ..engine_contract import EngineContract, EngineResult"
    )

# Convert simple CheckResult blocks
text = text.replace(
'''return CheckResult(
            name=self.name,
            status=Status.PASS,
            summary="mirror verification passed",
        )''',
'''return EngineResult(
            engine=self.name,
            action="verify",
            status="PASS",
            details={
                "summary": "verification passed",
            },
        )'''
)

text = text.replace(
'''return CheckResult(
            name=self.name,
            status=Status.PASS,
            summary="builder verification passed",
        )''',
'''return EngineResult(
            engine=self.name,
            action="verify",
            status="PASS",
            details={
                "summary": "verification passed",
            },
        )'''
)

text = text.replace(
'''return CheckResult(
            name=self.name,
            status=Status.PASS,
            summary="governance verification passed",
        )''',
'''return EngineResult(
            engine=self.name,
            action="verify",
            status="PASS",
            details={
                "summary": "verification passed",
            },
        )'''
)

text = text.replace(
'''return CheckResult(
            name=self.name,
            status=Status.PASS,
            summary="academy verification passed",
        )''',
'''return EngineResult(
            engine=self.name,
            action="verify",
            status="PASS",
            details={
                "summary": "verification passed",
            },
        )'''
)

path.write_text(text)

print("patched:", path)
PY
}

patch_engine "$ROOT/builder.py"
patch_engine "$ROOT/governance.py"
patch_engine "$ROOT/academy.py"

echo
echo "Compile check"
python3 -m compileall \
builder/python/wlplatform/wlplatform/engines

echo
echo "Migration complete"
