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


def graph_state_path(root: Path) -> Path:
    return root / "vault/08-Operations/state/wl-boot-graph.json"


def graph_logs(log_dir: Path) -> int:
    logs = sorted(log_dir.glob("wl-stage-*.log"), key=lambda p: p.stat().st_mtime, reverse=True)

    if not logs:
        warn(f"no graph logs found in {log_dir}")
        return 1

    print("Wonderland Graph Logs\n")
    for path in logs[:30]:
        size = path.stat().st_size
        print(f"{path.name:<36} {size:>8} bytes  {path}")
    return 0


def graph_state(root: Path) -> int:
    path = graph_state_path(root)
    if not path.exists():
        warn(f"boot graph state missing: {path}")
        return 1

    print(path.read_text(), end="")
    return 0


def graph_clean(root: Path, log_dir: Path) -> int:
    removed = 0

    state = graph_state_path(root)
    if state.exists():
        state.unlink()
        removed += 1

    for log in log_dir.glob("wl-stage-*.log"):
        log.unlink()
        removed += 1

    print(f"Removed {removed} graph artifact(s)")
    return 0


def graph_open_log(log_dir: Path, stage: str | None) -> int:
    if not stage:
        fail("usage: wl graph-open-log <stage>")
        return 1

    candidates = [
        log_dir / f"wl-stage-{stage}.log",
        log_dir / f"wl-stage-{stage}-health.log",
    ]

    existing = [p for p in candidates if p.exists()]
    if not existing:
        warn(f"no log found for stage: {stage}")
        print(f"searched: {', '.join(str(p) for p in candidates)}")
        return 1

    for path in existing:
        print(f"== {path} ==")
        print(path.read_text(errors="replace"), end="")
        if not str(path).endswith("\n"):
            print()

    return 0


def graph_current(root: Path) -> int:
    path = graph_state_path(root)
    if not path.exists():
        warn(f"boot graph state missing: {path}")
        print("Run: wl start")
        return 1

    data = json.loads(path.read_text())
    graph = data.get("graph", "unknown")
    updated_at = data.get("updated_at", "unknown")
    results = data.get("results", [])

    print("Wonderland Current Graph\n")
    print(f"Graph   {graph}")
    print(f"Updated {updated_at}\n")

    failed = False
    warned = False

    for item in results:
        state = item.get("state", "UNKNOWN")
        title = item.get("title", item.get("id", "unknown"))
        duration = float(item.get("duration", 0.0))

        if state == "PASS":
            color = GREEN
        elif state == "WARN":
            color = YELLOW
            warned = True
        else:
            color = RED
            failed = True

        print(f"{color}{state:<5}{RESET} {title:<26} {DIM}{duration:.2f}s{RESET}")

    print()

    if failed:
        fail("current graph degraded")
        print("RESULT FAIL")
        return 1

    if warned:
        warn("current graph has warnings")
        print("RESULT WARN")
        return 0

    ok("current graph healthy")
    print("RESULT PASS")
    return 0
