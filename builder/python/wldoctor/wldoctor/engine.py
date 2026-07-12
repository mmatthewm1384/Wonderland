from __future__ import annotations

from pathlib import Path
from typing import Any, Callable

from .adapters.repository import RepositoryAdapter


class DoctorEngine:
    def __init__(self, root: Path) -> None:
        self.root = root.resolve()

        self.adapters: list[Any] = [
            RepositoryAdapter(),
        ]

    def doctor(self) -> dict[str, Any]:
        systems: dict[str, Any] = {}

        for adapter in self.adapters:
            try:
                systems[adapter.name] = adapter.run(
                    self.root
                )
            except Exception as exc:
                systems[adapter.name] = {
                    "schema_version": 1,
                    "engine": adapter.name,
                    "status": "FAIL",
                    "error": str(exc),
                }

        status = (
            "PASS"
            if all(
                item.get("status") == "PASS"
                for item in systems.values()
            )
            else "FAIL"
        )

        return {
            "schema_version": 1,
            "engine": "wonderland-doctor",
            "version": "1.1",
            "status": status,
            "systems": systems,
        }
