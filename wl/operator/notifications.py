from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def notify(
    root: Path,
    source: str,
    level: str,
    title: str,
    message: str,
    payload: dict[str, Any] | None = None,
) -> None:
    path = root / "state" / "operator" / "notifications.jsonl"
    path.parent.mkdir(parents=True, exist_ok=True)

    event = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "source": source,
        "level": level,
        "title": title,
        "message": message,
        "payload": payload or {},
    }

    with path.open("a") as fh:
        fh.write(json.dumps(event, sort_keys=True) + "\n")


def recent(root: Path, limit: int = 6) -> list[dict[str, Any]]:
    path = root / "state" / "operator" / "notifications.jsonl"
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
