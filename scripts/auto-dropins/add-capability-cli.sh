#!/usr/bin/env bash
set -euo pipefail


echo "== Capability CLI Adapter =="


ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

TARGET="$ROOT/builder/python/wlplatform/wlplatform/cli.py"


cat > /tmp/capability_patch.py <<'PY'

from pathlib import Path


path = Path(
"builder/python/wlplatform/wlplatform/cli.py"
)


text = path.read_text()


if "capability" not in text:

    text += '''

# Registry v1.4 capability support

from .engines.capabilities import (
    list_capabilities,
    owner,
)

'''


path.write_text(text)

PY


python3 /tmp/capability_patch.py


echo "CLI adapter added"
