from __future__ import annotations

import subprocess
import time
from pathlib import Path


GREEN = "\033[38;2;47;230;107m"
CYAN = "\033[38;2;32;214;232m"
PURPLE = "\033[38;2;155;92;255m"
ORANGE = "\033[38;2;255;159;67m"
MUTED = "\033[38;2;102;112;133m"
RESET = "\033[0m"


def shell(cmd: str) -> str:
    return subprocess.getoutput(cmd).strip()


def exists(path: str) -> bool:
    return Path(path).exists()


def status_line(name: str, value: str, ok: bool | None = None) -> str:
    if ok is True:
        marker = f"{GREEN}●{RESET}"
    elif ok is False:
        marker = f"{ORANGE}●{RESET}"
    else:
        marker = f"{MUTED}●{RESET}"
    return f"  {marker} {PURPLE}{name:<12}{RESET} {value}"


def render(root: Path) -> None:
    branch = shell("git branch --show-current 2>/dev/null || true") or "unknown"
    changes = shell("git status --short 2>/dev/null | wc -l | tr -d ' '") or "0"

    runtime_state = exists("state/runtime/verify.json") or exists("state/runtime/startup.json")
    operator_state = exists("state/operator/operator.json")
    chaos_state = exists("vault/chaos/session.json") or exists("vault/05-Registry/chaos/lease.json")
    builder_state = exists("builder") or exists("builder/python/wlbuilder")

    print("\033[2J\033[H", end="")
    print(f"{GREEN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓{RESET}")
    print(f"{GREEN}┃                  Wonderland Operator                         ┃{RESET}")
    print(f"{GREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛{RESET}")
    print()
    print(f"{CYAN}live local-first operator environment{RESET}")
    print()
    print(f"{PURPLE}{'Root':<12}{RESET} {root}")
    print(f"{PURPLE}{'Branch':<12}{RESET} {branch}")
    print(f"{PURPLE}{'Git':<12}{RESET} {changes} changed files")
    print()
    print(f"{GREEN}Subsystems{RESET}")
    print(status_line("Operator", "running", operator_state))
    print(status_line("Runtime", "state detected" if runtime_state else "no runtime state", runtime_state))
    print(status_line("Builder", "available" if builder_state else "not detected", builder_state))
    print(status_line("Chaos", "state detected" if chaos_state else "no chaos state", chaos_state))
    print(status_line("Security", "planned", None))
    print()
    print(f"{CYAN}Windows{RESET}")
    print("  0 dashboard   1 runtime   2 builder   3 chaos")
    print("  4 security    5 logs      6 git       7 scratch")
    print()
    print(f"{ORANGE}Shortcuts{RESET}")
    print("  Ctrl-a d dashboard     Ctrl-a r runtime")
    print("  Ctrl-a b builder       Ctrl-a c chaos")
    print("  Ctrl-a s security      Ctrl-a L logs")
    print("  Ctrl-a g git           Ctrl-a x scratch")
    print()
    print(f"{MUTED}Refreshing every 2s. Press Ctrl-c to stop live dashboard.{RESET}")


def main() -> int:
    root = Path.cwd()
    while True:
        render(root)
        time.sleep(2)


if __name__ == "__main__":
    raise SystemExit(main())
