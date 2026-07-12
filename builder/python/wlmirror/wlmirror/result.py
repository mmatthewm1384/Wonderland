from __future__ import annotations

from dataclasses import asdict, dataclass, field
from enum import StrEnum
from typing import Any


class Status(StrEnum):
    PASS = "PASS"
    WARN = "WARN"
    FAIL = "FAIL"
    SKIP = "SKIP"
    IDLE = "IDLE"


@dataclass(frozen=True, slots=True)
class CheckResult:
    name: str
    status: Status
    summary: str
    duration_ms: int = 0
    details: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        payload = asdict(self)
        payload["status"] = self.status.value
        return payload


def aggregate(results: tuple[CheckResult, ...]) -> Status:
    if any(result.status is Status.FAIL for result in results):
        return Status.FAIL

    if any(result.status is Status.WARN for result in results):
        return Status.WARN

    if any(result.status is Status.IDLE for result in results):
        return Status.IDLE

    if results and all(
        result.status is Status.SKIP
        for result in results
    ):
        return Status.SKIP

    return Status.PASS
