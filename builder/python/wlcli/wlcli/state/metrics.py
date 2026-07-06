from __future__ import annotations

from collections import defaultdict
from pathlib import Path
from statistics import mean

from wlcli.state.history import read_history


def build_metrics(root: Path) -> dict:
    rows = read_history(root, limit=10000)

    if not rows:
        return {
            "run_count": 0,
            "pass_count": 0,
            "fail_count": 0,
            "average_duration": 0.0,
            "fastest_duration": 0.0,
            "slowest_duration": 0.0,
            "last_success": None,
            "last_failure": None,
            "stages": {},
        }

    durations = [float(r.get("duration", 0.0)) for r in rows]
    pass_rows = [r for r in rows if r.get("result") == "PASS"]
    fail_rows = [r for r in rows if r.get("result") != "PASS"]

    stage_durations: dict[str, list[float]] = defaultdict(list)
    stage_failures: dict[str, int] = defaultdict(int)

    for row in rows:
        for stage in row.get("stages", []):
            sid = stage.get("id", "unknown")
            stage_durations[sid].append(float(stage.get("duration", 0.0)))
            if stage.get("state") != "PASS":
                stage_failures[sid] += 1

    stages = {}
    for sid, values in stage_durations.items():
        stages[sid] = {
            "run_count": len(values),
            "average_duration": round(mean(values), 3),
            "fastest_duration": round(min(values), 3),
            "slowest_duration": round(max(values), 3),
            "failure_count": stage_failures.get(sid, 0),
        }

    return {
        "run_count": len(rows),
        "pass_count": len(pass_rows),
        "fail_count": len(fail_rows),
        "average_duration": round(mean(durations), 3),
        "fastest_duration": round(min(durations), 3),
        "slowest_duration": round(max(durations), 3),
        "last_success": pass_rows[-1].get("timestamp") if pass_rows else None,
        "last_failure": fail_rows[-1].get("timestamp") if fail_rows else None,
        "stages": stages,
    }
