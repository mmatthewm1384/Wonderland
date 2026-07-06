from __future__ import annotations

import json
from pathlib import Path

from wlcli.state.history import read_history
from wlcli.ui import BOLD, CYAN, DIM, GREEN, RED, RESET, YELLOW, warn


def history(root: Path, args: list[str]) -> int:
    limit = 20
    failures_only = "--failures" in args

    if "--last" in args:
        try:
            limit = int(args[args.index("--last") + 1])
        except Exception:
            warn("usage: wl history show --last <count>")
            return 1

    rows = read_history(root, limit=limit, failures_only=failures_only)

    print(f"{CYAN}{BOLD}Wonderland Runtime History{RESET}\n")

    if not rows:
        warn("no runtime history found")
        print("Run: wl start")
        return 1

    for row in rows:
        result = row.get("result", "UNKNOWN")
        color = GREEN if result == "PASS" else YELLOW if result == "WARN" else RED
        print(
            f"{color}{result:<5}{RESET} "
            f"{row.get('timestamp', 'unknown')} "
            f"{row.get('command', 'unknown'):<8} "
            f"{row.get('graph', 'unknown'):<8} "
            f"{DIM}{float(row.get('duration', 0.0)):.2f}s{RESET}"
        )

    return 0


def history_json(root: Path, args: list[str]) -> int:
    limit = 20
    failures_only = "--failures" in args

    if "--last" in args:
        try:
            limit = int(args[args.index("--last") + 1])
        except Exception:
            warn("usage: wl history export --json --last <count>")
            return 1

    print(json.dumps(read_history(root, limit=limit, failures_only=failures_only), indent=2))
    return 0
