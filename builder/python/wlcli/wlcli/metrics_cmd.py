from __future__ import annotations

import json
from pathlib import Path

from wlcli.state.metrics import build_metrics
from wlcli.ui import BOLD, CYAN, DIM, GREEN, RED, RESET, YELLOW, ok, warn


def metrics(root: Path) -> int:
    data = build_metrics(root)

    print(f"{CYAN}{BOLD}Wonderland Runtime Metrics{RESET}\n")

    if data["run_count"] == 0:
        warn("no runtime history found")
        print("Run: wl start")
        return 1

    print(f"Runs ................. {data['run_count']}")
    print(f"Pass ................. {data['pass_count']}")
    print(f"Fail ................. {data['fail_count']}")
    print(f"Average .............. {data['average_duration']:.2f}s")
    print(f"Fastest .............. {data['fastest_duration']:.2f}s")
    print(f"Slowest .............. {data['slowest_duration']:.2f}s")
    print(f"Last success ......... {data['last_success']}")
    print(f"Last failure ......... {data['last_failure']}")
    print()

    print(f"{BOLD}Stages{RESET}")
    for sid, item in sorted(data["stages"].items()):
        failures = int(item["failure_count"])
        color = GREEN if failures == 0 else YELLOW
        print(
            f"{color}{sid:<12}{RESET} "
            f"runs={item['run_count']:<4} "
            f"avg={item['average_duration']:.2f}s "
            f"fast={item['fastest_duration']:.2f}s "
            f"slow={item['slowest_duration']:.2f}s "
            f"fail={failures}"
        )

    print()
    ok("metrics generated")
    print("RESULT PASS")
    return 0


def metrics_json(root: Path) -> int:
    print(json.dumps(build_metrics(root), indent=2))
    return 0
