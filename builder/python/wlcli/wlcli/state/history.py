from __future__ import annotations

import json
import time
from dataclasses import asdict
from pathlib import Path
from typing import Any


def history_path(root: Path) -> Path:
    return root / "vault/08-Operations/state/runtime-history.jsonl"


def append_history(
    root: Path,
    *,
    command: str,
    result: str,
    duration: float,
    graph: str,
    stage_results: list[Any],
    profile: str = "default",
    runtime_instance: str = "wonderland-rootless",
) -> Path:
    path = history_path(root)
    path.parent.mkdir(parents=True, exist_ok=True)

    record = {
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "command": command,
        "result": result,
        "duration": duration,
        "graph": graph,
        "profile": profile,
        "runtime_instance": runtime_instance,
        "stages": [
            asdict(stage) if hasattr(stage, "__dataclass_fields__") else stage
            for stage in stage_results
        ],
    }

    with path.open("a") as f:
        f.write(json.dumps(record, sort_keys=True) + "\n")

    return path


def read_history(root: Path, limit: int = 20, failures_only: bool = False) -> list[dict]:
    path = history_path(root)
    if not path.exists():
        return []

    rows: list[dict] = []

    for line in path.read_text(errors="replace").splitlines():
        if not line.strip():
            continue

        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue

        if failures_only and row.get("result") == "PASS":
            continue

        rows.append(row)

    return rows[-limit:]
