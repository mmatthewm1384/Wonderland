from __future__ import annotations

from dataclasses import dataclass, field

from wl_controller.models.service import Service


@dataclass
class ServiceRegistry:
    services: list[Service] = field(default_factory=list)

    def by_name(self) -> dict[str, Service]:
        return {s.name: s for s in self.services}

    def to_dict(self) -> dict:
        return {
            "services": [s.to_dict() for s in self.services],
            "total": len(self.services),
            "ready": len([s for s in self.services if s.ready()]),
            "drifted": len([s for s in self.services if s.drift]),
        }
