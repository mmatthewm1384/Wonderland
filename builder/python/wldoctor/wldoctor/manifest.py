from __future__ import annotations

from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True)
class DoctorSystem:
    name: str
    version: str
    enabled: bool = True

    def as_dict(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "version": self.version,
            "enabled": self.enabled,
        }


DEFAULT_MANIFEST = [
    DoctorSystem(
        name="repository",
        version="1.2.2",
    ),
]


def manifest() -> list[dict[str, Any]]:
    return [
        item.as_dict()
        for item in DEFAULT_MANIFEST
    ]
