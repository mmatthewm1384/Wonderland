from __future__ import annotations

from dataclasses import dataclass, asdict
from datetime import UTC, datetime


@dataclass
class Spark:
    name: str
    owner: str
    runtime: str = "alpine"
    status: str = "CREATED"

    created: str = datetime.now(UTC).isoformat()

    def to_dict(self):
        return asdict(self)
