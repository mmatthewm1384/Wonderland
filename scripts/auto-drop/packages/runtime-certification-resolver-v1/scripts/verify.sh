#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

python3 - <<PY
import sys

sys.path.insert(
0,
"$WL_ROOT/builder/python/wlplatform/src"
)

from wlplatform.runtime.certification.resolver import (
    RuntimeCertificationResolver
)

print("IMPORT OK")
PY

echo "CERTIFIED"

