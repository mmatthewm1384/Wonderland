from __future__ import annotations

from wlcli.models import Report
from wlcli.ui import BOLD, CYAN, DIM, GREEN, RED, RESET, YELLOW, fail, ok, warn


def state_color(state: str) -> str:
    if state == "PASS":
        return GREEN
    if state == "WARN":
        return YELLOW
    return RED


def render_report(report: Report) -> int:
    print(f"{CYAN}{BOLD}{report.title}{RESET}")

    for key, value in report.metadata.items():
        print(f"{DIM}{key}:{RESET} {value}")

    if report.metadata:
        print()

    for line in report.lines:
        color = state_color(line.state)
        duration = f" {DIM}{line.duration:.2f}s{RESET}" if line.duration else ""
        print(f"{color}{line.state:<5}{RESET} {line.title:<26}{duration}")
        if line.detail:
            print(f"      {line.detail}")

    if report.lines:
        print()

    if report.state == "PASS":
        ok(report.message or "report healthy")
        print("RESULT PASS")
        return 0

    if report.state == "WARN":
        warn(report.message or "report has warnings")
        print("RESULT WARN")
        return 0

    fail(report.message or "report failed")
    print("RESULT FAIL")
    return 1
