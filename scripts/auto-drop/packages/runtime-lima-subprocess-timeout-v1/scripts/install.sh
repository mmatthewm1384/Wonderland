#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$(pwd)}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime"

mkdir -p "$TARGET"

cat > "$TARGET/subprocess_timeout.py" <<'PY'
from __future__ import annotations

import subprocess
from dataclasses import dataclass


@dataclass
class SubprocessResult:
    command: list[str]
    returncode: int
    stdout: str
    stderr: str


class SubprocessTimeoutError(RuntimeError):
    pass


def run_command(command: list[str], timeout_seconds: int = 30) -> SubprocessResult:
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=timeout_seconds,
            check=False,
        )

        return SubprocessResult(
            command=command,
            returncode=result.returncode,
            stdout=result.stdout,
            stderr=result.stderr,
        )

    except subprocess.TimeoutExpired as exc:
        raise SubprocessTimeoutError(
            f"Command exceeded timeout: {command}"
        ) from exc
PY

echo "INSTALL PASS"
