#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

OUT="$WL_ROOT/vault/08-Operations/runtime/recovery-checkpoint"

mkdir -p "$OUT"

python3 - <<PY
from pathlib import Path
import subprocess
import json
from datetime import datetime, timezone

root = Path("$WL_ROOT")

result = {
    "timestamp": datetime.now(timezone.utc).isoformat(),
    "python_import": False,
    "git_status": [],
}

try:
    import sys
    sys.path.insert(
        0,
        str(root / "builder/python/wlplatform/src")
    )

    import wlplatform.services.runtime_service

    result["python_import"] = True

except Exception as e:
    result["python_error"] = str(e)


try:
    result["git_status"] = subprocess.check_output(
        [
            "git",
            "status",
            "--short"
        ],
        cwd=root,
        text=True
    ).splitlines()

except Exception as e:
    result["git_error"] = str(e)


(root / "vault/08-Operations/runtime/recovery-checkpoint/evidence.json").write_text(
    json.dumps(result, indent=2)
)

print(json.dumps(result, indent=2))
PY

echo "Checkpoint created"
