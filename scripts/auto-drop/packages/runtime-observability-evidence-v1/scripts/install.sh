#!/bin/sh
set -eu

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/evidence.py"

mkdir -p "$(dirname "$TARGET")"

cat > "$TARGET" <<'PY'
from datetime import datetime
import json
from pathlib import Path


class RuntimeEvidence:

    def __init__(self, root):
        self.root = Path(root)

    def collect(
        self,
        target,
        adapter,
        status
    ):

        evidence = {
            "timestamp": datetime.utcnow().isoformat(),
            "runtime": {
                "target": target,
                "adapter": adapter,
                "status": status
            }
        }

        output = (
            self.root
            / "vault/08-Operations/evidence/runtime"
        )

        output.mkdir(
            parents=True,
            exist_ok=True
        )

        artifact = (
            output
            / "runtime-status.json"
        )

        artifact.write_text(
            json.dumps(
                evidence,
                indent=2
            )
        )

        return str(artifact)
PY

echo "runtime evidence collector installed"
