from __future__ import annotations

import json
from pathlib import Path

from wlcli.core.events.bus import RuntimeEvent
from wlcli.core.runtime.context import RuntimeContext


class MetricsSubscriber:
    name = "metrics"

    def handle(self, context: RuntimeContext, event: RuntimeEvent) -> None:
        if event.type not in ("stage.completed", "stage.failed", "graph.completed", "graph.failed"):
            return

        path = context.state_file("runtime-metrics.events.json")
        path.parent.mkdir(parents=True, exist_ok=True)

        if path.exists():
            try:
                data = json.loads(path.read_text())
            except Exception:
                data = {}
        else:
            data = {}

        data.setdefault("events_processed", 0)
        data.setdefault("graphs", {})
        data.setdefault("stages", {})

        data["events_processed"] += 1
        data["last_event"] = event.timestamp

        payload = event.payload

        if event.type.startswith("graph."):
            graph = str(payload.get("graph", "unknown"))
            item = data["graphs"].setdefault(
                graph,
                {"completed": 0, "failed": 0, "last_duration": 0.0},
            )
            if event.type == "graph.completed":
                item["completed"] += 1
            else:
                item["failed"] += 1
            item["last_duration"] = float(payload.get("duration", 0.0))

        if event.type.startswith("stage."):
            stage = str(payload.get("stage", "unknown"))
            item = data["stages"].setdefault(
                stage,
                {"completed": 0, "failed": 0, "last_duration": 0.0},
            )
            if event.type == "stage.completed":
                item["completed"] += 1
            else:
                item["failed"] += 1
            item["last_duration"] = float(payload.get("duration", 0.0))

        path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
