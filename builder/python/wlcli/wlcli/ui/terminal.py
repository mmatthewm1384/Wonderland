from __future__ import annotations

from wlcli.output import CommandResult

CYAN = "\033[38;2;0;229;255m"
PURPLE = "\033[38;2;112;0;255m"
GREEN = "\033[38;2;0;255;102m"
YELLOW = "\033[38;2;255;212;71m"
RED = "\033[38;2;255;51;102m"
DIM = "\033[2m"
BOLD = "\033[1m"
RESET = "\033[0m"


def color_for(state: str) -> str:
    if state == "PASS":
        return GREEN
    if state == "WARN":
        return YELLOW
    return RED


def render(result: CommandResult) -> int:
    print(f"{CYAN}{BOLD}{result.title}{RESET}")

    for key, value in result.metadata.items():
        print(f"{DIM}{key}:{RESET} {value}")

    if result.metadata:
        print()

    for line in result.lines:
        color = color_for(line.state)
        duration = f" {DIM}{line.duration:.2f}s{RESET}" if line.duration else ""
        print(f"{color}{line.state:<5}{RESET} {line.title:<28}{duration}")
        if line.detail:
            print(f"      {line.detail}")

    if result.lines:
        print()

    color = color_for(result.state)
    if result.message:
        print(f"{color}{result.state}{RESET} {result.message}")

    print(f"{color}RESULT {result.state}{RESET}")
    return result.exit_code()
