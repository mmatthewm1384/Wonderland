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
        self.subscribers = []

    def register(self, subscriber) -> None:
        self.subscribers.append(subscriber)

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

        self._append(event)

        for subscriber in self.subscribers:
            subscriber.handle(self.context, event)

        return event

    def _append(self, event: RuntimeEvent) -> None:
        with self.path.open("a") as f:
            f.write(json.dumps(asdict(event), sort_keys=True) + "\n")

    def read(self, limit: int = 50, event_type: str | None = None) -> list[dict]:
        rows = self.read_all(event_type=event_type)
        return rows[-limit:]

    def read_all(self, event_type: str | None = None) -> list[dict]:
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

        return rows

    def replay(self, subscribers: list) -> int:
        count = 0

        for row in self.read_all():
            event = RuntimeEvent(
                id=str(row.get("id", "")),
                timestamp=str(row.get("timestamp", "")),
                type=str(row.get("type", "")),
                source=str(row.get("source", "")),
                severity=str(row.get("severity", "INFO")),
                payload=dict(row.get("payload", {})),
            )

            for subscriber in subscribers:
                subscriber.handle(self.context, event)

            count += 1

        return count

    def clear(self) -> int:
        if not self.path.exists():
            return 0

        count = len(self.path.read_text(errors="replace").splitlines())
        self.path.unlink()
        return count
