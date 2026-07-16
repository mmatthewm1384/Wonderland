#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

echo "== Wonderland Platform Registry Engine Auto Drop-In =="


echo
echo "Searching wlplatform engine implementation..."

TARGET=$(grep -RIl \
    "NOT_IMPLEMENTED\|engine.*registry\|registry.*verify" \
    builder/python/wlplatform/wlplatform \
    2>/dev/null \
    | grep -v __pycache__ \
    | head -1 || true)


if [[ -z "$TARGET" ]]; then
    echo "ERROR: No wlplatform engine registry implementation found"
    exit 1
fi


echo "Candidate:"
echo "$TARGET"


cp "$TARGET" "$TARGET.bak.$(date +%Y%m%d%H%M%S)"


python3 - "$TARGET" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])

text = path.read_text()

print("Inspecting:", path)


if "wl registry" in text:
    print("Registry delegation already present")
    raise SystemExit(0)


if "NOT_IMPLEMENTED" not in text:
    print("No patch point in this file")
    raise SystemExit(1)


replacement = """

def registry_verify():
    import json
    import subprocess

    result = subprocess.run(
        [
            "bin/wl",
            "registry",
            "--json"
        ],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        return {
            "engine": "registry",
            "action": "verify",
            "status": "FAIL",
            "details": {
                "stderr": result.stderr
            }
        }

    return {
        "engine": "registry",
        "action": "verify",
        "status": "PASS",
        "details": json.loads(result.stdout)
    }

"""


text = text.replace(
    "NOT_IMPLEMENTED",
    replacement
)


path.write_text(text)

print("Updated:", path)

PY


echo
echo "== Verify =="

wl-platform engine registry --json
