from __future__ import annotations

from dataclasses import dataclass, field, asdict


@dataclass
class Service:
    name: str
    desired: bool = True
    running: bool = False
    healthy: bool = False
    critical: bool = False
    image: str = ""
    status: str = ""
    dependencies: list[str] = field(default_factory=list)
    health: dict = field(default_factory=dict)
    drift: list[str] = field(default_factory=list)

    def ready(self) -> bool:
        return self.desired and self.running and self.healthy

    def to_dict(self) -> dict:
        data = asdict(self)
        data["ready"] = self.ready()
        return data
