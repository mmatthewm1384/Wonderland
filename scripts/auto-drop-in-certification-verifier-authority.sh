#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

echo "== Wonderland Certification Verifier Authority Migration =="

cd "$ROOT"

STAMP=$(date +"%Y%m%d-%H%M%S")

echo
echo "== Backup =="

cp \
builder/python/wlplatform/wlplatform/certification/certifier.py \
builder/python/wlplatform/wlplatform/certification/certifier.py.backup.$STAMP

cp \
builder/python/wlplatform/wlplatform/certification/platform.py \
builder/python/wlplatform/wlplatform/certification/platform.py.backup.$STAMP


echo
echo "== Locate legacy authority =="

grep -R \
"certifications/engines" \
builder/python/wlplatform/wlplatform \
|| true


echo
echo "== Patch verifier imports =="


python3 <<'PY'

from pathlib import Path

files = [
    Path(
    "builder/python/wlplatform/wlplatform/certification/certifier.py"
    ),
    Path(
    "builder/python/wlplatform/wlplatform/certification/platform.py"
    )
]


for path in files:

    if not path.exists():
        continue

    text = path.read_text()

    text = text.replace(
        'certifications/engines',
        'certifications/registry.json'
    )

    path.write_text(text)

    print("UPDATED", path)

PY


echo
echo "== Verify registry authority =="

./bin/wl-platform verify

echo
echo "== COMPLETE =="
