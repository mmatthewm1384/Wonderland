#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

STAMP=$(date +"%Y%m%d-%H%M%S")

echo "== Certification Authority v2 =="

TARGETS=$(grep -rl \
"certifications/engines" \
builder/python/wlplatform/wlplatform \
--exclude="*.bak*" \
--exclude="*.backup*" \
|| true)

if [ -z "$TARGETS" ]; then
    echo "No legacy authority references found"
    exit 0
fi


for FILE in $TARGETS; do

    cp "$FILE" "$FILE.backup.$STAMP"

    python3 - "$FILE" <<'PY'

from pathlib import Path
import sys

p = Path(sys.argv[1])

text = p.read_text()

text = text.replace(
    "certifications/engines",
    "certifications/normalized"
)

p.write_text(text)

print("UPDATED", p)

PY

done


echo
echo "== Verify =="

./bin/wl-platform verify
