from __future__ import annotations

import json
import time
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Callable, Iterable


@dataclass(frozen=True)
class Event:
    ts: float
    type: str
    payload: dict


class EventBus:
    def __init__(self, event_log: Path):
        self.event_log = event_log
        self.event_log.parent.mkdir(parents=True, exist_ok=True)
        self._subscribers: list[Callable[[Event], None]] = []

    def subscribe(self, fn: Callable[[Event], None]) -> None:
        self._subscribers.append(fn)

    def publish(self, event_type: str, payload: dict | None = None) -> Event:
        event = Event(ts=time.time(), type=event_type, payload=payload or {})
        with self.event_log.open("a", encoding="utf-8") as f:
            f.write(json.dumps(asdict(event), sort_keys=True) + "\n")

        for subscriber in self._subscribers:
            subscriber(event)

        return event

    def read_recent(self, limit: int = 100) -> list[dict]:
        if not self.event_log.exists():
            return []

        lines = self.event_log.read_text(encoding="utf-8").splitlines()
        out: list[dict] = []

        for line in lines[-limit:]:
            try:
                out.append(json.loads(line))
            except json.JSONDecodeError:
                continue

        return out
