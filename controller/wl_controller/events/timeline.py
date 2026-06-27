from __future__ import annotations

import json
from pathlib import Path

from wl_controller.events.bus import Event


class TimelineWriter:
    def __init__(self, timeline_dir: Path):
        self.timeline_dir = timeline_dir
        self.timeline_dir.mkdir(parents=True, exist_ok=True)

    def __call__(self, event: Event) -> None:
        seq = int(event.ts * 1000)
        safe = event.type.replace(".", "-")
        path = self.timeline_dir / f"{seq}-{safe}.json"
        path.write_text(json.dumps({
            "ts": event.ts,
            "type": event.type,
            "payload": event.payload,
        }, indent=2, sort_keys=True), encoding="utf-8")

    def status(self) -> dict:
        entries = sorted(self.timeline_dir.glob("*.json"))
        return {
            "entries": len(entries),
            "latest": entries[-1].name if entries else None,
        }
