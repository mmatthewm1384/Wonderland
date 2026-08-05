#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters"

mkdir -p "$TARGET"

cat > "$TARGET/lima_adapter.py" <<'PY'
import subprocess


class LimaRuntimeAdapter:

    def __init__(self, instance="wonderland-rootless"):
        self.instance = instance

    def status(self):
        result = subprocess.run(
            [
                "limactl",
                "list",
                "--json"
            ],
            capture_output=True,
            text=True
        )

        return {
            "instance": self.instance,
            "available": result.returncode == 0,
            "raw": result.stdout
        }

    def start(self):
        return subprocess.run(
            [
                "limactl",
                "start",
                self.instance
            ],
            capture_output=True,
            text=True
        ).returncode == 0

    def stop(self):
        return subprocess.run(
            [
                "limactl",
                "stop",
                self.instance
            ],
            capture_output=True,
            text=True
        ).returncode == 0
PY

echo "Lima adapter installed"
