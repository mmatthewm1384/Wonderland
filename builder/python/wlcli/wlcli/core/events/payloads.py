from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Any


@dataclass(frozen=True)
class GraphPayload:
    graph: str
    duration: float = 0.0
    stage_count: int = 0

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class StagePayload:
    graph: str
    stage: str
    title: str
    state: str = ""
    code: int = 0
    duration: float = 0.0
    log: str = ""

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)
