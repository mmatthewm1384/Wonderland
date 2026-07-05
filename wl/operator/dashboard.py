from __future__ import annotations

import subprocess
import time
from pathlib import Path

from wl.operator.core import HealthState, OperatorContext
from wl.operator.registry import discover
from wl.operator.events import recent_events
from wl.operator.notifications import recent as recent_notifications


GREEN = "\033[38;2;47;230;107m"
CYAN = "\033[38;2;32;214;232m"
PURPLE = "\033[38;2;155;92;255m"
ORANGE = "\033[38;2;255;159;67m"
RED = "\033[38;2;255;86;86m"
MUTED = "\033[38;2;102;112;133m"
RESET = "\033[0m"


def shell(cmd: str) -> str:
    return subprocess.getoutput(cmd).strip()


def marker(state: HealthState) -> str:
    if state == HealthState.HEALTHY:
        return f"{GREEN}●{RESET}"
    if state == HealthState.BUSY:
        return f"{CYAN}●{RESET}"
    if state == HealthState.WARNING:
        return f"{ORANGE}●{RESET}"
    if state == HealthState.FAILED:
        return f"{RED}●{RESET}"
    return f"{MUTED}●{RESET}"


def render(root: Path) -> None:
    context = OperatorContext(root=root, state_dir=root / "state" / "operator")
    capabilities = discover(context)

    branch = shell("git branch --show-current 2>/dev/null || true") or "unknown"
    changes = shell("git status --short 2>/dev/null | wc -l | tr -d ' '") or "0"

    print("\033[2J\033[H", end="")
    print(f"{GREEN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓{RESET}")
    print(f"{GREEN}┃                  Wonderland Operator                         ┃{RESET}")
    print(f"{GREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛{RESET}")
    print()
    print(f"{CYAN}capability-driven local operator environment{RESET}")
    print()
    print(f"{PURPLE}{'Root':<12}{RESET} {root}")
    print(f"{PURPLE}{'Branch':<12}{RESET} {branch}")
    print(f"{PURPLE}{'Git':<12}{RESET} {changes} changed files")
    print()
    print(f"{GREEN}Capabilities{RESET}")

    for cap in capabilities:
        print(
            f"  {marker(cap.health.state)} "
            f"{PURPLE}{cap.title:<12}{RESET} "
            f"{cap.health.message}"
        )

    print()
    print(f"{CYAN}Windows{RESET}")
    print("  0 dashboard   1 runtime   2 builder   3 chaos")
    print("  4 security    5 logs      6 git       7 scratch")
    print()
    notifications = recent_notifications(root)
    events = recent_events(root)

    print(f"{ORANGE}Notifications{RESET}")
    if notifications:
        for item in notifications[-4:]:
            print(f"  {item.get('level', 'info'):<7} {item.get('title', '')} - {item.get('message', '')}")
    else:
        print("  none")
    print()

    print(f"{CYAN}Recent Events{RESET}")
    if events:
        for item in events[-4:]:
            print(f"  {item.get('source', ''):<10} {item.get('type', '')}")
    else:
        print("  none")
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
