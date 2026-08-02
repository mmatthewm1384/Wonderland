#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

mkdir -p \
"$ROOT/builder/python/wlplatform/src/wlplatform/runtime/health"


cat > "$ROOT/builder/python/wlplatform/src/wlplatform/runtime/health/__init__.py" <<'PY'
from .lima_health import LimaHealth
from .nerdctl_health import NerdctlHealth
from .evidence import RuntimeEvidence

__all__ = [
    "LimaHealth",
    "NerdctlHealth",
    "RuntimeEvidence",
]
PY


cat > "$ROOT/builder/python/wlplatform/src/wlplatform/runtime/health/lima_health.py" <<'PY'
import subprocess


class LimaHealth:

    def __init__(
        self,
        instance="wonderland-rootless"
    ):
        self.instance = instance


    def check(self):

        result = subprocess.run(
            [
                "limactl",
                "list",
                self.instance
            ],
            capture_output=True,
            text=True,
            check=False
        )

        return {
            "component": "lima",
            "instance": self.instance,
            "status": "PASS"
            if result.returncode == 0
            else "FAIL",
            "exit_code": result.returncode,
            "stdout": result.stdout.strip()
        }
PY


cat > "$ROOT/builder/python/wlplatform/src/wlplatform/runtime/health/nerdctl_health.py" <<'PY'
import subprocess


class NerdctlHealth:

    def __init__(
        self,
        instance="wonderland-rootless"
    ):
        self.instance = instance


    def check(self):

        result = subprocess.run(
            [
                "limactl",
                "shell",
                self.instance,
                "nerdctl",
                "ps"
            ],
            capture_output=True,
            text=True,
            check=False
        )

        return {
            "component": "nerdctl",
            "status": "PASS"
            if result.returncode == 0
            else "FAIL",
            "exit_code": result.returncode,
            "stdout": result.stdout.strip()
        }
PY


cat > "$ROOT/builder/python/wlplatform/src/wlplatform/runtime/health/evidence.py" <<'PY'
from datetime import datetime, timezone


class RuntimeEvidence:

    def generate(
        self,
        checks
    ):

        return {
            "schema": "wonderland.runtime.health.v1",
            "timestamp":
                datetime.now(timezone.utc).isoformat(),
            "checks": checks,
            "status":
                "PASS"
                if all(
                    x["status"] == "PASS"
                    for x in checks
                )
                else "FAIL"
        }
PY

echo "Runtime health observability installed"
