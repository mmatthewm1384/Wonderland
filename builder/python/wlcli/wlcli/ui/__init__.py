from __future__ import annotations

import itertools
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path

CYAN = "\033[38;2;0;229;255m"
PURPLE = "\033[38;2;112;0;255m"
GREEN = "\033[38;2;0;255;102m"
YELLOW = "\033[38;2;255;212;71m"
RED = "\033[38;2;255;51;102m"
DIM = "\033[2m"
BOLD = "\033[1m"
RESET = "\033[0m"


def logo() -> None:
    print(f"{PURPLE}╭────────────────────────────────────╮{RESET}")
    print(f"{PURPLE}│{RESET} {CYAN}{BOLD}Wonderland Runtime{RESET} {DIM}orchestrator{RESET}       {PURPLE}│{RESET}")
    print(f"{PURPLE}╰────────────────────────────────────╯{RESET}")


def ok(message: str) -> None:
    print(f"{GREEN}PASS{RESET} {message}")


def warn(message: str) -> None:
    print(f"{YELLOW}WARN{RESET} {message}")


def fail(message: str) -> None:
    print(f"{RED}FAIL{RESET} {message}")


@dataclass(frozen=True)
class StepResult:
    name: str
    code: int
    log: Path
    duration: float


def run_step(name: str, command: list[str], log_dir: Path) -> StepResult:
    log_dir.mkdir(parents=True, exist_ok=True)
    safe = "".join(c if c.isalnum() else "_" for c in name).strip("_")
    log = log_dir / f"wl-{safe}.log"

    start = time.time()

    with log.open("w") as f:
        proc = subprocess.Popen(command, stdout=f, stderr=subprocess.STDOUT)

        frames = itertools.cycle(["◐", "◓", "◑", "◒"])
        colors = itertools.cycle([CYAN, PURPLE, GREEN, PURPLE])

        while proc.poll() is None:
            sys.stdout.write(f"\r{next(colors)}{next(frames)}{RESET} {name}")
            sys.stdout.flush()
            time.sleep(0.12)

        code = proc.wait()

    duration = time.time() - start

    if code == 0:
        sys.stdout.write(f"\r{GREEN}●{RESET} {name} {DIM}{duration:.2f}s{RESET}\n")
    else:
        sys.stdout.write(f"\r{RED}●{RESET} {name} {DIM}{duration:.2f}s{RESET}\n")

    return StepResult(name=name, code=code, log=log, duration=duration)
