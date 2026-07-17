#!/usr/bin/env bash
set -euo pipefail

echo "== Extend Engine Contract v1.1 =="

ROOT="/Users/wonderland/Wonderland"

FILE="$ROOT/builder/python/wlplatform/wlplatform/engine_contract.py"

python3 <<PY
from pathlib import Path

p = Path("$FILE")

text = p.read_text()

marker = "    def metadata(self):"

if marker not in text:

    addition = '''

    def metadata(self):

        return {
            "engine": self.name,
            "version": getattr(
                self,
                "version",
                "1.0.0"
            ),
            "owner": getattr(
                self,
                "owner",
                f"platform.{self.name}"
            ),
            "capabilities": getattr(
                self,
                "capabilities",
                []
            )
        }

'''

    text += addition

    p.write_text(text)

print("PASS")
PY
