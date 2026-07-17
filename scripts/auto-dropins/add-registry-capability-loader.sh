#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

TARGET="$ROOT/builder/python/wlplatform/wlplatform/engines/capabilities.py"

cat > "$TARGET" <<'PY'
from pathlib import Path
import json


class CapabilityRegistry:

    def __init__(self, root):

        self.root = Path(root)

        self.path = (
            self.root
            /
            "vault/05-Registry/engines/engine-index.json"
        )


    def load(self):

        if not self.path.exists():
            return {}

        return json.loads(
            self.path.read_text()
        )


    def engine(self, name):

        data = self.load()

        return (
            data
            .get("engines", {})
            .get(name)
        )
PY


echo "Capability loader created"

python3 -m compileall \
"$TARGET"

echo "PASS"
