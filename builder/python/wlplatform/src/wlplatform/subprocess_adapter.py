from __future__ import annotations

import subprocess
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence

from .context import PlatformContext
from .result import CheckResult, Status


@dataclass(frozen=True, slots=True)
class CommandSpec:
    name: str
    commands: tuple[tuple[str, ...], ...]
    timeout: int = 180
    required: bool = True
    idle_patterns: tuple[str, ...] = ()
    warning_patterns: tuple[str, ...] = (
        "result warn",
    )


def _executable_exists(
    root: Path,
    command: Sequence[str],
) -> bool:
    if not command:
        return False

    executable = command[0]

    if executable.startswith("bin/"):
        path = root / executable
        return path.is_file() and path.stat().st_mode & 0o111 != 0

    if executable.startswith("./"):
        path = root / executable[2:]
        return path.is_file() and path.stat().st_mode & 0o111 != 0

    return True


def select_command(
    root: Path,
    candidates: Iterable[Sequence[str]],
) -> tuple[str, ...] | None:
    for candidate in candidates:
        if _executable_exists(root, candidate):
            return tuple(candidate)

    return None


def run_command(
    context: PlatformContext,
    spec: CommandSpec,
) -> CheckResult:
    command = select_command(
        context.root,
        spec.commands,
    )

    if command is None:
        return CheckResult(
            name=spec.name,
            status=(
                Status.FAIL
                if spec.required
                else Status.SKIP
            ),
            summary=(
                "required subsystem command unavailable"
                if spec.required
                else "optional subsystem command unavailable"
            ),
        )

    started = time.monotonic()

    try:
        completed = subprocess.run(
            list(command),
            cwd=context.root,
            env=context.environment(),
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=spec.timeout,
            check=False,
        )
    except subprocess.TimeoutExpired as exc:
        return CheckResult(
            name=spec.name,
            status=Status.FAIL,
            summary=f"verification timed out after {spec.timeout}s",
            duration_ms=round(
                (time.monotonic() - started) * 1000
            ),
            command=command,
            stdout=(exc.stdout or "").strip(),
            stderr=(exc.stderr or "").strip(),
        )
    except OSError as exc:
        return CheckResult(
            name=spec.name,
            status=Status.FAIL,
            summary=f"verification could not execute: {exc}",
            duration_ms=round(
                (time.monotonic() - started) * 1000
            ),
            command=command,
            stderr=str(exc),
        )

    duration_ms = round(
        (time.monotonic() - started) * 1000
    )
    stdout = completed.stdout.strip()
    stderr = completed.stderr.strip()
    combined = f"{stdout}\n{stderr}".lower()

    if completed.returncode != 0:
        status = Status.FAIL
        summary = (
            f"verification exited {completed.returncode}"
        )
    elif "result fail" in combined:
        status = Status.FAIL
        summary = "verification output reported failure"
    elif any(
        pattern.lower() in combined
        for pattern in spec.idle_patterns
    ):
        status = Status.IDLE
        summary = "subsystem is intentionally idle"
    elif any(
        pattern.lower() in combined
        for pattern in spec.warning_patterns
    ):
        status = Status.WARN
        summary = "verification completed with warnings"
    else:
        status = Status.PASS
        summary = "verification passed"

    return CheckResult(
        name=spec.name,
        status=status,
        summary=summary,
        duration_ms=duration_ms,
        command=command,
        exit_code=completed.returncode,
        stdout=stdout,
        stderr=stderr,
    )
