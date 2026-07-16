#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

echo "== Registry Engine Migration =="

TARGET="builder/python/wlplatform/wlplatform/engines.py"

if [[ ! -f "$TARGET" ]]; then
    echo "Missing:"
    echo "$TARGET"
    exit 1
fi


cp "$TARGET" "$TARGET.bak.$(date +%Y%m%d-%H%M%S)"


python3 <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/engines.py"
)

text = path.read_text()


old = """
class RegistryEngine(EngineContract):
"""

if old not in text:
    print("RegistryEngine already migrated or not found")
    raise SystemExit(0)


start = text.index(old)


# find next class after RegistryEngine
remaining = text[start:]
next_class = remaining.find(
    "\nclass ",
    len(old)
)

if next_class == -1:
    end = len(text)
else:
    end = start + next_class


replacement = """
# RegistryEngine moved to:
# wlplatform.engines.registry.RegistryEngine
#
# Kept here as compatibility marker only.

"""


text = (
    text[:start]
    +
    replacement
    +
    text[end:]
)


path.write_text(text)

print("Migrated RegistryEngine ownership")

PY


echo
echo "Verify:"
wl-platform engine registry --json
