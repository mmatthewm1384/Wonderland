from __future__ import annotations

import json
import time
from dataclasses import dataclass, field, asdict
from pathlib import Path


@dataclass
class PlatformState:
    schema: int = 1
    generated_at: float = field(default_factory=time.time)
    runtime: dict = field(default_factory=dict)
    registry: dict = field(default_factory=dict)
    desired_state: dict = field(default_factory=dict)
    containers: list[dict] = field(default_factory=list)
    health: dict = field(default_factory=dict)
    deployment: dict = field(default_factory=dict)
    recovery: dict = field(default_factory=dict)
    controller: dict = field(default_factory=dict)
    timeline: dict = field(default_factory=dict)
    metrics: dict = field(default_factory=dict)
    certification: dict = field(default_factory=dict)
    events: list[dict] = field(default_factory=list)

    def to_dict(self) -> dict:
        return asdict(self)

    def save(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(self.to_dict(), indent=2, sort_keys=True), encoding="utf-8")
