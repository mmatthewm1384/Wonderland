#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

WL="$ROOT/builder/python/wlplatform/wlplatform"

echo "=========================================="
echo "Reality Engine Registry Integration v0.1"
echo "=========================================="


############################################
# Find ownership registry
############################################

OWNERSHIP="$WL/certification/ownership.py"

if [ ! -f "$OWNERSHIP" ]; then
    echo "ERROR: ownership registry not found"
    exit 1
fi


############################################
# Backup
############################################

cp "$OWNERSHIP" \
"$OWNERSHIP.backup.$(date +%Y%m%d-%H%M%S)"


############################################
# Add ownership entry
############################################

python3 <<'PY'

from pathlib import Path

path = Path(
"/Users/wonderland/Wonderland/builder/python/wlplatform/wlplatform/certification/ownership.py"
)

text = path.read_text()

entry = '''
    "reality.engine": "academy.matrix",
'''

if '"reality.engine"' not in text:

    marker = "OWNERSHIP = {"

    if marker not in text:
        raise SystemExit(
            "OWNERSHIP dictionary not found"
        )

    text = text.replace(
        marker,
        marker + entry
    )

    path.write_text(text)

    print(
        "Added reality.engine ownership"
    )

else:
    print(
        "reality.engine already registered"
    )

PY


############################################
# Create capability manifest location
############################################

mkdir -p \
"$ROOT/registry/capabilities"


cat > \
"$ROOT/registry/capabilities/reality.engine.json" \
<<'EOF'
{
  "capability": "reality.engine",
  "version": "0.1.0",
  "owner": "academy.matrix",
  "status": "experimental",
  "certification": [
    "schema",
    "tests",
    "documentation",
    "reproducibility"
  ]
}
EOF


############################################
# Verify import
############################################

python3 <<'PY'

import sys

sys.path.insert(
0,
"/Users/wonderland/Wonderland/builder/python/wlplatform"
)

from wlplatform.certification.ownership import OWNERSHIP

assert "reality.engine" in OWNERSHIP

print(
"ownership registration PASS"
)

PY


echo
echo "Reality Engine registry integration complete"
