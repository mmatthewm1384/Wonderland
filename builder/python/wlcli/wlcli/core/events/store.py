from __future__ import annotations

import json
from dataclasses import asdict, is_dataclass
from pathlib import Path
from typing import Any

from wlcli.core.runtime.context import RuntimeContext


class EventStore:
    def append(self, event: Any) -> None:
        raise NotImplementedError

    def read_all(self, event_type: str | None = None) -> list[dict]:
        raise NotImplementedError

    def clear(self) -> int:
        raise NotImplementedError


class JsonlEventStore(EventStore):
    def __init__(self, context: RuntimeContext):
        self.context = context
        self.path = context.state_file("runtime-events.jsonl")
        self.path.parent.mkdir(parents=True, exist_ok=True)

    def append(self, event: Any) -> None:
        if is_dataclass(event):
            row = asdict(event)
        elif hasattr(event, "to_dict"):
            row = event.to_dict()
        else:
            row = dict(event)

        with self.path.open("a") as f:
            f.write(json.dumps(row, sort_keys=True) + "\n")

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

    def clear(self) -> int:
        if not self.path.exists():
            return 0

        count = len([line for line in self.path.read_text(errors="replace").splitlines() if line.strip()])
        self.path.unlink()
        return count
