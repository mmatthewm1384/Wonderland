from __future__ import annotations

from pathlib import Path

from wlcli.graph import BootGraph
from wlcli.report import build_graph_current, graph_state_path
from wlcli.ui import BOLD, CYAN, DIM, GREEN, RED, RESET, YELLOW, fail, ok, warn


def graph_doctor(root: Path, log_dir: Path) -> int:
    graph = BootGraph(
        root=root,
        log_dir=log_dir,
        state_file=graph_state_path(root),
    )

    failed = False

    print(f"{CYAN}{BOLD}Wonderland Graph Doctor{RESET}\n")

    valid, messages = graph.validate(graph.start_stages())
    if valid:
        ok("boot graph structure valid")
    else:
        failed = True
        fail("boot graph structure invalid")

    for message in messages:
        if "health" in message:
            warn(message)
        else:
            fail(message)

    state = graph_state_path(root)
    if state.exists():
        ok(f"state file present: {state}")
    else:
        warn(f"state file missing: {state}")

    logs = sorted(log_dir.glob("wl-stage-*.log"))
    if logs:
        ok(f"stage logs present: {len(logs)}")
    else:
        warn(f"no stage logs found in {log_dir}")

    report = build_graph_current(root)
    if report.state == "FAIL":
        failed = True
        fail(report.message or "current graph failed")
    elif report.state == "WARN":
        warn(report.message or "current graph has warnings")
    else:
        ok(report.message or "current graph healthy")

    print()

    if failed:
        print(f"{RED}RESULT FAIL{RESET}")
        return 1

    print(f"{GREEN}RESULT PASS{RESET}")
    return 0
