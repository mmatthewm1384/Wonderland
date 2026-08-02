#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

TARGET="$ROOT/builder/python/wlplatform/src/wlplatform/runtime/adapters/lima.py"

mkdir -p "$(dirname "$TARGET")"


cat > "$TARGET" <<'PY'
from pathlib import Path
import subprocess


class LimaAdapter:

    def __init__(
        self,
        instance="wonderland-rootless"
    ):
        self.instance = instance


    def _run(self, command):

        try:

            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                check=False
            )

            return {
                "command": command,
                "exit_code": result.returncode,
                "stdout": result.stdout.strip(),
                "stderr": result.stderr.strip()
            }

        except Exception as exc:

            return {
                "command": command,
                "error": str(exc)
            }


    def start(self):

        return self._run(
            [
                "limactl",
                "start",
                self.instance
            ]
        )


    def stop(self):

        return self._run(
            [
                "limactl",
                "stop",
                self.instance
            ]
        )


    def status(self):

        lima = self._run(
            [
                "limactl",
                "list",
                self.instance
            ]
        )

        return {
            "adapter": "lima",
            "instance": self.instance,
            "lima": lima
        }


    def nerdctl_status(self):

        return self._run(
            [
                "limactl",
                "shell",
                self.instance,
                "nerdctl",
                "ps"
            ]
        )
PY


echo "Production Lima adapter installed"

