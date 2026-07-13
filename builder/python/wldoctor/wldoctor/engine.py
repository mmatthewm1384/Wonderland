from __future__ import annotations

from pathlib import Path
from typing import Any

from .adapters.repository import RepositoryAdapter
from .manifest import manifest


class DoctorEngine:
    def __init__(self, root: Path) -> None:
        self.root = root.resolve()

        self.adapters = {
            "repository": RepositoryAdapter(),
        }

    def doctor(self) -> dict[str, Any]:
        systems: dict[str, Any] = {}

        for name, adapter in self.adapters.items():
            try:
                systems[name] = adapter.run(self.root)
            except Exception as exc:
                systems[name] = {
                    "schema_version": 1,
                    "engine": name,
                    "status": "FAIL",
                    "error": str(exc),
                }

        passed = [
            item.get("status") == "PASS"
            for item in systems.values()
        ]

        status = (
            "PASS"
            if all(passed)
            else "FAIL"
        )

        health_scores = [
            item.get("health", {}).get("score")
            for item in systems.values()
            if isinstance(
                item.get("health"),
                dict,
            )
            and isinstance(
                item["health"].get("score"),
                int,
            )
        ]

        health = (
            sum(health_scores) // len(health_scores)
            if health_scores
            else 0
        )

        certification = {
            name: {
                "certified": item.get("certified", False),
                "health_score": item.get(
                    "health",
                    {},
                ).get(
                    "score",
                    0,
                ),
            }
            for name, item in systems.items()
        }

        certification["overall"] = status == "PASS"

        return {
            "schema_version": 1,
            "engine": "wonderland-doctor",
            "version": "1.2.1",
            "status": status,
            "health_score": health,
            "manifest": manifest(),
            "systems": systems,
            "certification": certification,
            "certified": status == "PASS",
        }
