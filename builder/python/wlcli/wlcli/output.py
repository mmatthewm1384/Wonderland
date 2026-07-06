from __future__ import annotations

from dataclasses import asdict, dataclass, field
import json
from typing import Any


@dataclass(frozen=True)
class ResultLine:
    state: str
    title: str
    detail: str = ""
    duration: float = 0.0


@dataclass(frozen=True)
class CommandResult:
    title: str
    state: str
    message: str = ""
    lines: list[ResultLine] = field(default_factory=list)
    metadata: dict[str, str] = field(default_factory=dict)
    payload: Any | None = None

    def exit_code(self) -> int:
        return 0 if self.state in ("PASS", "WARN") else 1

    def to_dict(self) -> dict:
        return asdict(self)

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), indent=2)
