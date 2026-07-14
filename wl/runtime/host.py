from __future__ import annotations

import platform
import subprocess


def is_linux() -> bool:
    return platform.system() == "Linux"


def is_macos() -> bool:
    return platform.system() == "Darwin"


def run(cmd: list[str], timeout: float = 30.0) -> bool:
    try:
        subprocess.run(cmd, timeout=timeout, check=True)
        return True
    except Exception:
        return False
