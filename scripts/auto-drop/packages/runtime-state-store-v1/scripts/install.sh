#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/state"

mkdir -p "$TARGET"

cat > "$TARGET/store.py" <<'PY'
from pathlib import Path
from datetime import datetime, timezone
import json


class RuntimeStateStore:

    def __init__(self, root):
        self.path = (
            Path(root)
            / "vault"
            / "08-Operations"
            / "runtime"
            / "state.json"
        )

    def write(
        self,
        action,
        target,
        result,
        adapter=None
    ):
        self.path.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        data = {
            "action": action,
            "target": target,
            "adapter": adapter,
            "result": result,
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat()
        }

        self.path.write_text(
            json.dumps(
                data,
                indent=2
            )
        )

        return data

    def read(self):
        if not self.path.exists():
            return {}

        return json.loads(
            self.path.read_text()
        )
PY

echo "Runtime state store installed"
