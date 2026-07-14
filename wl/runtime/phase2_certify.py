from __future__ import annotations

import subprocess
import sys
from dataclasses import dataclass


@dataclass(frozen=True)
class Check:
    name: str
    command: tuple[str, ...]


CHECKS: tuple[Check, ...] = (
    Check("compile runtime", (sys.executable, "-m", "compileall", "wl/runtime")),
    Check("phase2 verify", (sys.executable, "-m", "wl.runtime.phase2_verify")),
    Check("phase2 launcher verify", (sys.executable, "-m", "wl.runtime.phase2_launcher_verify")),
    Check("phase2 stable verify", (sys.executable, "-m", "wl.runtime.phase2_stable_verify")),
    Check("runtime smoke start", (sys.executable, "-m", "wl.runtime.start", "--ticks", "1", "--no-alt-screen")),
)


def run_check(check: Check) -> bool:
    print(f"==> {check.name}")
    completed = subprocess.run(check.command, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if completed.stdout.strip():
        print(completed.stdout.strip())
    if completed.returncode != 0:
        print(f"FAIL {check.name}: exit {completed.returncode}", file=sys.stderr)
        return False
    print(f"PASS {check.name}")
    return True


def main() -> int:
    for check in CHECKS:
        if not run_check(check):
            print("FAIL runtime phase2 certification", file=sys.stderr)
            return 1
    print("PASS runtime phase2 certification")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
