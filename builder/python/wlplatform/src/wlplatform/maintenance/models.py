from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any


PASS = "PASS"
WARN = "WARN"
FAIL = "FAIL"


@dataclass(frozen=True)
class MaintenanceCheck:
    id: str
    result: str
    message: str
    category: str = "general"
    duration_ms: float | None = None
    details: dict[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class ProviderStatus:
    id: str
    installed: bool
    healthy: bool
    version: str | None = None
    prefix: str | None = None


@dataclass(frozen=True)
class MaintenanceStatus:

    provider: ProviderStatus
    checks: list[MaintenanceCheck]

    generated_at: str = field(
        default_factory=lambda:
        datetime.now(timezone.utc).isoformat()
    )

    @property
    def result(self):
        if any(c.result == FAIL for c in self.checks):
            return FAIL

        if any(c.result == WARN for c in self.checks):
            return WARN

        return PASS
