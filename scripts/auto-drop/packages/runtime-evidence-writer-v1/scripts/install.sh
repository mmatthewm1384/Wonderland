#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/evidence.py"

mkdir -p "$(dirname "$TARGET")"

cat > "$TARGET" <<'PY'
from pathlib import Path
from datetime import datetime, timezone
import json


class RuntimeEvidenceWriter:

    def __init__(self, root):
        self.path = (
            Path(root)
            / "runtime"
            / "events"
            / "runtime-lifecycle.jsonl"
        )

        self.path.parent.mkdir(
            parents=True,
            exist_ok=True
        )


    def write(self, action, adapter):
        event = {
            "service": "runtime",
            "action": action,
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat(),
            "adapter": adapter
        }

        with self.path.open("a") as f:
            f.write(
                json.dumps(event)
                + "\n"
            )

        return event
PY

python3 -m compileall "$TARGET"

echo "Runtime evidence writer installed"
