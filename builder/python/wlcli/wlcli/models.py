from __future__ import annotations

from dataclasses import asdict, dataclass, field
import json


@dataclass(frozen=True)
class ReportLine:
    state: str
    title: str
    duration: float = 0.0
    detail: str = ""


@dataclass(frozen=True)
class Report:
    title: str
    state: str
    lines: list[ReportLine] = field(default_factory=list)
    metadata: dict[str, str] = field(default_factory=dict)
    message: str = ""

    def to_dict(self) -> dict:
        return asdict(self)

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), indent=2)
