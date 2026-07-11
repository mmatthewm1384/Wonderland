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
    command: tuple[str, ...] = ()
    exit_code: int | None = None
    stdout: str = ""
    stderr: str = ""
    details: dict[str, Any] = field(default_factory=dict)

    @property
    def failed(self) -> bool:
        return self.status is Status.FAIL

    @property
    def successful(self) -> bool:
        return self.status in {
            Status.PASS,
            Status.WARN,
            Status.SKIP,
            Status.IDLE,
        }

    def to_dict(self) -> dict[str, Any]:
        payload = asdict(self)
        payload["status"] = self.status.value
        payload["command"] = list(self.command)
        return payload


@dataclass(frozen=True, slots=True)
class PlatformReport:
    schema_version: int
    engine_version: str
    root: str
    result: Status
    duration_ms: int
    checks: tuple[CheckResult, ...]

    @property
    def exit_code(self) -> int:
        return 1 if self.result is Status.FAIL else 0

    def to_dict(self) -> dict[str, Any]:
        return {
            "schema_version": self.schema_version,
            "engine_version": self.engine_version,
            "root": self.root,
            "result": self.result.value,
            "duration_ms": self.duration_ms,
            "checks": [
                check.to_dict()
                for check in self.checks
            ],
            "summary": {
                status.value.lower(): sum(
                    check.status is status
                    for check in self.checks
                )
                for status in Status
            },
        }


def aggregate_status(
    checks: tuple[CheckResult, ...],
) -> Status:
    if any(check.status is Status.FAIL for check in checks):
        return Status.FAIL

    if any(check.status is Status.WARN for check in checks):
        return Status.WARN

    if any(check.status is Status.IDLE for check in checks):
        return Status.IDLE

    if checks and all(
        check.status is Status.SKIP
        for check in checks
    ):
        return Status.SKIP

    return Status.PASS
