from __future__ import annotations

import json
from pathlib import Path

from wlcli.ui import BOLD, CYAN, DIM, GREEN, RED, RESET, YELLOW, fail, warn


def boot_report(root: Path) -> int:
    state_file = root / "vault/08-Operations/state/wl-boot-graph.json"

    if not state_file.exists():
        warn(f"boot graph state missing: {state_file}")
        print("Run: wl start")
        return 1

    data = json.loads(state_file.read_text())
    graph = data.get("graph", "unknown")
    updated_at = data.get("updated_at", "unknown")
    results = data.get("results", [])

    print(f"{CYAN}{BOLD}Wonderland Boot Report{RESET}")
    print(f"{DIM}Graph:{RESET} {graph}")
    print(f"{DIM}Updated:{RESET} {updated_at}\n")

    failed = False

    for item in results:
        state = item.get("state", "UNKNOWN")
        title = item.get("title", item.get("id", "unknown"))
        duration = float(item.get("duration", 0.0))
        log = item.get("log", "")

        color = GREEN if state == "PASS" else YELLOW if state == "WARN" else RED
        print(f"{color}{state:<5}{RESET} {title:<26} {DIM}{duration:.2f}s{RESET}")

        if state == "FAIL":
            failed = True
            print(f"      log: {log}")

    print()

    if failed:
        fail("last boot graph had failures")
        print("RESULT FAIL")
        return 1

    print(f"{GREEN}RESULT PASS{RESET}")
    return 0
