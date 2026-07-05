from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def emit(root: Path, source: str, event_type: str, payload: dict[str, Any] | None = None) -> None:
    path = root / "state" / "operator" / "events.jsonl"
    path.parent.mkdir(parents=True, exist_ok=True)

    event = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "source": source,
        "type": event_type,
        "payload": payload or {},
    }

    with path.open("a") as fh:
        fh.write(json.dumps(event, sort_keys=True) + "\n")


def recent_events(root: Path, limit: int = 8) -> list[dict[str, Any]]:
    path = root / "state" / "operator" / "events.jsonl"
    if not path.exists():
        return []

    lines = path.read_text().splitlines()[-limit:]
    items: list[dict[str, Any]] = []

    for line in lines:
        try:
            items.append(json.loads(line))
        except json.JSONDecodeError:
            continue

    return items
