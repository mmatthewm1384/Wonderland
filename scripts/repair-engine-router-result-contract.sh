#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
from pathlib import Path

p = Path(
    "builder/python/wlplatform/wlplatform/engine_router.py"
)

text = p.read_text()

old = """        return result.to_dict()
"""

new = """        if hasattr(result, "to_dict"):
            return result.to_dict()

        if isinstance(result, dict):
            return result

        raise TypeError(
            f"engine result does not implement to_dict: {type(result)!r}"
        )
"""

if old not in text:
    raise SystemExit(
        "expected return contract not found"
    )

text = text.replace(old, new)

p.write_text(text)

print(
    "patched engine_router.py"
)
PY
