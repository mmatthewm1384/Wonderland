#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/services/runtime_service.py"
BACKUP="$TARGET.runtime-adapter-result-normalizer-v1.bak"

cp "$TARGET" "$BACKUP"

python3 - "$TARGET" <<'PY'
from pathlib import Path
import sys

target = Path(sys.argv[1])

text = target.read_text()

if "_normalize_adapter_result" not in text:

    marker = "    def _event(self, action, result):"

    insert = """
    def _normalize_adapter_result(self, result):

        if isinstance(result, bool):
            return {
                "success": result
            }

        if result is None:
            return {
                "success": False
            }

        if isinstance(result, dict):
            return result

        return {
            "success": bool(result),
            "value": str(result)
        }


"""

    if marker not in text:
        raise SystemExit("event marker missing")

    text = text.replace(
        marker,
        insert + marker
    )


old = """        event = {
"""

new = """        result = self._normalize_adapter_result(result)

        event = {
"""

if old in text and new not in text:
    text = text.replace(
        old,
        new,
        1
    )

text = text.replace(
    "\\n",
    "\n"
)

target.write_text(text)

PY

python3 -m compileall "$TARGET"

echo "Runtime adapter normalization installed"
