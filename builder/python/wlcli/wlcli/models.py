from __future__ import annotations

from dataclasses import dataclass, field


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
