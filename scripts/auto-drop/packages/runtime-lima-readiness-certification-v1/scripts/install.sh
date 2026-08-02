#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/lima"

mkdir -p "$TARGET"

cat > "$TARGET/readiness_certification.py" <<'PY'
from __future__ import annotations

from dataclasses import dataclass
import platform
import shutil
import subprocess


@dataclass
class RuntimeCertification:
    lima_running: bool
    kernel_verified: bool
    nerdctl_available: bool


def lima_running(name: str = "wonderland-rootless") -> bool:
    result = subprocess.run(
        [
            "limactl",
            "list",
            "--format",
            "{{.Name}}\t{{.Status}}",
        ],
        capture_output=True,
        text=True,
        check=False,
    )

    return any(
        line == f"{name}\tRunning"
        for line in result.stdout.splitlines()
    )


def certify() -> RuntimeCertification:
    return RuntimeCertification(
        lima_running=lima_running(),
        kernel_verified=platform.system() == "Linux",
        nerdctl_available=shutil.which("nerdctl") is not None,
    )
PY

echo "INSTALL PASS"
