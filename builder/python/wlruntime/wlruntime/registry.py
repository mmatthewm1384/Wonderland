from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any

from .errors import RegistryValidationError
from .models import EngineDefinition


class EngineRegistry:
    SCHEMA_VERSION = 1

    def __init__(self, registry_path: Path):
        self.registry_path = registry_path.resolve()
        self._raw: dict[str, Any] = {}
        self._engines: dict[str, EngineDefinition] = {}
        self.reload()

    def reload(self) -> None:
        try:
            raw = json.loads(
                self.registry_path.read_text(encoding="utf-8")
            )
        except OSError as exc:
            raise RegistryValidationError(
                f"cannot read registry: {exc}"
            ) from exc
        except json.JSONDecodeError as exc:
            raise RegistryValidationError(
                f"invalid registry JSON at line {exc.lineno}: {exc.msg}"
            ) from exc

        if not isinstance(raw, dict):
            raise RegistryValidationError(
                "registry root must be an object"
            )

        if raw.get("schema_version") != self.SCHEMA_VERSION:
            raise RegistryValidationError(
                "unsupported registry schema version"
            )

        raw_engines = raw.get("engines")

        if not isinstance(raw_engines, dict) or not raw_engines:
            raise RegistryValidationError(
                "registry.engines must be a non-empty object"
            )

        engines: dict[str, EngineDefinition] = {}
        problems: list[str] = []

        for engine_id in sorted(raw_engines):
            try:
                engines[engine_id] = EngineDefinition.from_dict(
                    engine_id,
                    raw_engines[engine_id],
                )
            except ValueError as exc:
                problems.append(str(exc))

        for engine_id, engine in sorted(engines.items()):
            for dependency in engine.dependencies:
                if dependency not in engines:
                    problems.append(
                        f"engines.{engine_id}: unresolved dependency "
                        f"{dependency!r}"
                    )

        if not problems:
            try:
                self._topological_sort(engines)
            except RegistryValidationError as exc:
                problems.append(str(exc))

        if problems:
            raise RegistryValidationError("; ".join(problems))

        self._raw = raw
        self._engines = engines

    @property
    def engines(self) -> dict[str, EngineDefinition]:
        return dict(self._engines)

    def engine(self, engine_id: str) -> EngineDefinition:
        try:
            return self._engines[engine_id]
        except KeyError as exc:
            raise RegistryValidationError(
                f"unknown engine: {engine_id}"
            ) from exc

    def engine_ids(self) -> tuple[str, ...]:
        return tuple(sorted(self._engines))

    def start_order(self) -> tuple[str, ...]:
        return self._topological_sort(self._engines)

    def stop_order(self) -> tuple[str, ...]:
        return tuple(reversed(self.start_order()))

    def graph(self) -> dict[str, Any]:
        return {
            "schema_version": self.SCHEMA_VERSION,
            "nodes": [
                {
                    "id": engine_id,
                    "description": self._engines[engine_id].description,
                    "required": self._engines[engine_id].required,
                }
                for engine_id in sorted(self._engines)
            ],
            "edges": [
                {
                    "from": dependency,
                    "to": engine_id,
                }
                for engine_id in sorted(self._engines)
                for dependency in sorted(
                    self._engines[engine_id].dependencies
                )
            ],
            "start_order": list(self.start_order()),
            "stop_order": list(self.stop_order()),
        }

    def digest(self) -> str:
        canonical = json.dumps(
            self._raw,
            sort_keys=True,
            separators=(",", ":"),
        )
        return hashlib.sha256(
            canonical.encode("utf-8")
        ).hexdigest()

    @staticmethod
    def _topological_sort(
        engines: dict[str, EngineDefinition],
    ) -> tuple[str, ...]:
        indegree = {
            engine_id: 0
            for engine_id in engines
        }
        dependents = {
            engine_id: set()
            for engine_id in engines
        }

        for engine_id, engine in engines.items():
            for dependency in engine.dependencies:
                indegree[engine_id] += 1
                dependents[dependency].add(engine_id)

        ready = sorted(
            engine_id
            for engine_id, degree in indegree.items()
            if degree == 0
        )
        ordered: list[str] = []

        while ready:
            engine_id = ready.pop(0)
            ordered.append(engine_id)

            for dependent in sorted(dependents[engine_id]):
                indegree[dependent] -= 1

                if indegree[dependent] == 0:
                    ready.append(dependent)
                    ready.sort()

        if len(ordered) != len(engines):
            cyclic = sorted(
                engine_id
                for engine_id, degree in indegree.items()
                if degree > 0
            )
            raise RegistryValidationError(
                "dependency cycle detected: " + ", ".join(cyclic)
            )

        return tuple(ordered)
