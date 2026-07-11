"""Governance result models."""

from __future__ import annotations

from dataclasses import asdict, dataclass, field
from typing import Any


@dataclass(frozen=True)
class CheckResult:
    check_id: str
    status: str
    required: bool
    command: list[str]
    returncode: int | None
    duration_seconds: float
    stdout: str = ""
    stderr: str = ""
    error: str | None = None

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass
class GovernanceReport:
    mode: str
    result: str
    created_at: str
    checks: dict[str, CheckResult] = field(default_factory=dict)
    failures: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    metadata: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        return {
            "mode": self.mode,
            "result": self.result,
            "created_at": self.created_at,
            "checks": {
                name: check.to_dict()
                for name, check in self.checks.items()
            },
            "failures": self.failures,
            "warnings": self.warnings,
            "metadata": self.metadata,
        }
