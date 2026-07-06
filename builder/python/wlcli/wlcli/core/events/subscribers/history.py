from __future__ import annotations

import json
from pathlib import Path

from wlcli.core.events.bus import RuntimeEvent
from wlcli.core.runtime.context import RuntimeContext


class HistorySubscriber:
    name = "history"

    def handle(self, context: RuntimeContext, event: RuntimeEvent) -> None:
        if event.type not in ("graph.completed", "graph.failed"):
            return

        payload = event.payload
        path = context.state_file("runtime-history.events.jsonl")
        path.parent.mkdir(parents=True, exist_ok=True)

        result = "PASS" if event.type == "graph.completed" else "FAIL"

        record = {
            "timestamp": event.timestamp,
            "command": str(payload.get("graph", "runtime")).lower(),
            "result": result,
            "duration": float(payload.get("duration", 0.0)),
            "graph": str(payload.get("graph", "unknown")),
            "profile": context.profile,
            "runtime_instance": context.runtime_instance,
            "source_event": event.id,
        }

        with path.open("a") as f:
            f.write(json.dumps(record, sort_keys=True) + "\n")
