from __future__ import annotations

import json
from pathlib import Path

from wlcli.output import CommandResult, ResultLine
from wlcli.core.ui import fail, warn


def graph_state_path(root: Path) -> Path:
    return root / "vault/08-Operations/state/wl-boot-graph.json"


def load_graph_state(root: Path) -> tuple[dict, str | None]:
    path = graph_state_path(root)

    if not path.exists():
        return {}, f"boot graph state missing: {path}"

    try:
        return json.loads(path.read_text()), None
    except json.JSONDecodeError as e:
        return {}, f"boot graph state invalid JSON: {e}"


def build_boot_report(root: Path) -> CommandResult:
    data, error = load_graph_state(root)

    if error:
        return CommandResult(
            title="Wonderland Boot Report",
            state="FAIL",
            message=error,
            metadata={"Run": "wl start"},
        )

    results = data.get("results", [])
    lines: list[ResultLine] = []

    failed = False
    warned = False

    for item in results:
        state = item.get("state", "UNKNOWN")

        if state == "FAIL":
            failed = True
        elif state == "WARN":
            warned = True

        lines.append(
            ResultLine(
                state=state,
                title=item.get("title", item.get("id", "unknown")),
                duration=float(item.get("duration", 0.0)),
                detail=f"log: {item.get('log', '')}" if state == "FAIL" else "",
            )
        )

    overall = "FAIL" if failed else "WARN" if warned else "PASS"

    return CommandResult(
        title="Wonderland Boot Report",
        state=overall,
        lines=lines,
        metadata={
            "Graph": str(data.get("graph", "unknown")),
            "Updated": str(data.get("updated_at", "unknown")),
        },
        message="last boot graph had failures"
        if failed
        else "last boot graph has warnings"
        if warned
        else "last boot graph healthy",
        payload=data,
    )


def build_graph_current(root: Path) -> CommandResult:
    data, error = load_graph_state(root)

    if error:
        return CommandResult(
            title="Wonderland Current Graph",
            state="FAIL",
            message=error,
            metadata={"Run": "wl start"},
        )

    results = data.get("results", [])
    lines: list[ResultLine] = []

    failed = False
    warned = False

    for item in results:
        state = item.get("state", "UNKNOWN")

        if state == "FAIL":
            failed = True
        elif state == "WARN":
            warned = True

        lines.append(
            ResultLine(
                state=state,
                title=item.get("title", item.get("id", "unknown")),
                duration=float(item.get("duration", 0.0)),
            )
        )

    overall = "FAIL" if failed else "WARN" if warned else "PASS"

    return CommandResult(
        title="Wonderland Current Graph",
        state=overall,
        lines=lines,
        metadata={
            "Graph": str(data.get("graph", "unknown")),
            "Updated": str(data.get("updated_at", "unknown")),
        },
        message="current graph degraded"
        if failed
        else "current graph has warnings"
        if warned
        else "current graph healthy",
        payload=data,
    )


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
        print()

    return 0
