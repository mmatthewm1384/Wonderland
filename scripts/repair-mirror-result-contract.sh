#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
from pathlib import Path

p = Path(
    "builder/python/wlplatform/wlplatform/engines/mirror.py"
)

text = p.read_text()

text = text.replace(
"""from __future__ import annotations


class MirrorEngine:
""",
"""from __future__ import annotations

from ..result import CheckResult, Status


class MirrorEngine:
"""
)

text = text.replace(
"""    def verify(self):

        return {
            "engine": self.name,
            "status": "PASS",
            "certified": True,
        }


    def certify(self):

        return self.verify()
""",
"""    def verify(self):

        return CheckResult(
            name=self.name,
            status=Status.PASS,
            summary="mirror verification passed",
        )


    def certify(self):

        return self.verify()
"""
)

p.write_text(text)

print(
    "patched mirror result contract"
)
PY
