#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

BASE="builder/python/wldoctor/wldoctor"

echo "Applying Doctor Engine 1.2..."

cat > "$BASE/manifest.py" <<'PY'
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
PY


cat > "$BASE/engine.py" <<'PY'
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

        return {
            "schema_version": 1,
            "engine": "wonderland-doctor",
            "version": "1.2",
            "status": status,
            "health_score": health,
            "manifest": manifest(),
            "systems": systems,
            "certified": status == "PASS",
        }
PY


echo "Running Doctor Engine tests..."

PYTHONPATH=builder/python/wldoctor:builder/python/wlrepository \
python -m pytest builder/python/wldoctor/tests

echo
echo "Doctor output..."

./bin/wl doctor --json

echo
echo "Doctor Engine 1.2 applied."
