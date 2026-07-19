#!/usr/bin/env bash
set -euo pipefail

FILE="builder/python/wlplatform/wlplatform/engine_router.py"

if [ ! -f "$FILE" ]; then
    echo "ERROR: missing $FILE"
    exit 1
fi

cp "$FILE" "${FILE}.backup.$(date +%Y%m%d-%H%M%S)"

python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/engine_router.py"
)

text = path.read_text()

if "normalize_engine_result" not in text:

    text = text.replace(
        "from .engines import get_engine\n",
        "from .engines import get_engine\n"
        "from .engine_contract_adapter import normalize_engine_result\n"
    )

old = """        result = method()

        if action == "certify":
            instance.write_artifact(result)

        if hasattr(result, "to_dict"):
            return result.to_dict()

        if isinstance(result, dict):
            return result

        raise TypeError(
            f"engine result does not implement to_dict: {type(result)!r}"
        )
"""

new = """        result = normalize_engine_result(
            method(),
            engine=engine,
            action=action,
        )

        return result.to_dict()
"""

    if old not in text:
        raise SystemExit(
            "ERROR: expected router block not found"
        )

    text = text.replace(
        old,
        new,
    )

path.write_text(text)

print("patched:", path)
PY

echo
echo "Verification:"
python3 -m py_compile \
builder/python/wlplatform/wlplatform/engine_router.py

echo "PASS"
