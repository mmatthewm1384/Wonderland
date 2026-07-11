"""Safe subprocess execution for governance checks."""

from __future__ import annotations

import os
import subprocess
import time
from pathlib import Path

from .models import CheckResult


class CommandRunner:
    def __init__(self, root: Path):
        self.root = root.resolve()

    def run(
        self,
        *,
        check_id: str,
        command: list[str],
        required: bool = True,
        timeout_seconds: int = 300,
    ) -> CheckResult:
        started = time.monotonic()

        environment = os.environ.copy()
        environment["WL_ROOT"] = str(self.root)
        environment["WL_HOME"] = str(self.root)
        environment["PATH"] = os.pathsep.join(
            [
                str(self.root / "bin"),
                "/opt/homebrew/bin",
                "/opt/homebrew/sbin",
                "/usr/local/bin",
                "/usr/bin",
                "/bin",
                "/usr/sbin",
                "/sbin",
            ]
        )

        try:
            completed = subprocess.run(
                command,
                cwd=self.root,
                env=environment,
                text=True,
                capture_output=True,
                check=False,
                timeout=timeout_seconds,
            )
        except subprocess.TimeoutExpired as exc:
            return CheckResult(
                check_id=check_id,
                status="FAIL",
                required=required,
                command=command,
                returncode=None,
                duration_seconds=round(
                    time.monotonic() - started,
                    6,
                ),
                stdout=exc.stdout or "",
                stderr=exc.stderr or "",
                error=(
                    f"timeout after {timeout_seconds} seconds"
                ),
            )
        except OSError as exc:
            return CheckResult(
                check_id=check_id,
                status="FAIL",
                required=required,
                command=command,
                returncode=None,
                duration_seconds=round(
                    time.monotonic() - started,
                    6,
                ),
                error=f"{type(exc).__name__}: {exc}",
            )

        return CheckResult(
            check_id=check_id,
            status=(
                "PASS"
                if completed.returncode == 0
                else "FAIL"
            ),
            required=required,
            command=command,
            returncode=completed.returncode,
            duration_seconds=round(
                time.monotonic() - started,
                6,
            ),
            stdout=completed.stdout,
            stderr=completed.stderr,
            error=(
                None
                if completed.returncode == 0
                else f"exit status {completed.returncode}"
            ),
        )
