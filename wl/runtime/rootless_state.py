from __future__ import annotations

import json
import platform
import subprocess
from typing import Any


ROOTLESS_INSTANCE = "wonderland-rootless"
ROOTLESS_STATE_DIR = "~/.local/state/wonderland/runtime"


def is_macos() -> bool:
    return platform.system() == "Darwin"


def read_rootless_json(name: str) -> dict[str, Any]:
    cmd = [
        "limactl",
        "shell",
        ROOTLESS_INSTANCE,
        "bash",
        "-lc",
        f"cat {ROOTLESS_STATE_DIR}/{name}",
    ]

    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        timeout=20,
        check=True,
    )

    return json.loads(result.stdout)
