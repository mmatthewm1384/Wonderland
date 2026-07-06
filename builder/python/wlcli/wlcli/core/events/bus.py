from __future__ import annotations

import json
import time
import uuid
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any

from wlcli.core.runtime.context import RuntimeContext


@dataclass(frozen=True)
class RuntimeEvent:
    id: str
    timestamp: str
    type: str
    source: str
    severity: str = "INFO"
    payload: dict[str, Any] = field(default_factory=dict)


class EventBus:
    def __init__(self, context: RuntimeContext):
        self.context = context
        self.path = context.state_file("runtime-events.jsonl")
        self.path.parent.mkdir(parents=True, exist_ok=True)

    def emit(
        self,
        event_type: str,
        *,
        source: str,
        severity: str = "INFO",
        payload: dict[str, Any] | None = None,
    ) -> RuntimeEvent:
        event = RuntimeEvent(
            id=str(uuid.uuid4()),
            timestamp=time.strftime("%Y-%m-%dT%H:%M:%S%z"),
            type=event_type,
            source=source,
            severity=severity,
            payload=payload or {},
        )

        with self.path.open("a") as f:
            f.write(json.dumps(asdict(event), sort_keys=True) + "\n")

        return event

    def read(self, limit: int = 50, event_type: str | None = None) -> list[dict]:
        if not self.path.exists():
            return []

        rows: list[dict] = []

        for line in self.path.read_text(errors="replace").splitlines():
            if not line.strip():
                continue
            try:
                row = json.loads(line)
            except json.JSONDecodeError:
                continue

            if event_type and row.get("type") != event_type:
                continue

            rows.append(row)

        return rows[-limit:]
