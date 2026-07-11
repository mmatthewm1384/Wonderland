from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


VALID_ACTIONS = frozenset({"start", "stop", "verify"})


@dataclass(frozen=True)
class CommandSpec:
    argv: tuple[str, ...]
    timeout_seconds: int = 300
    environment: dict[str, str] = field(default_factory=dict)

    @classmethod
    def from_dict(
        cls,
        value: Any,
        *,
        context: str,
    ) -> "CommandSpec | None":
        if value is None:
            return None

        if not isinstance(value, dict):
            raise ValueError(f"{context} must be an object or null")

        argv = value.get("argv")

        if not isinstance(argv, list) or not argv:
            raise ValueError(f"{context}.argv must be a non-empty list")

        if not all(isinstance(item, str) and item for item in argv):
            raise ValueError(
                f"{context}.argv entries must be non-empty strings"
            )

        timeout = value.get("timeout_seconds", 300)

        if not isinstance(timeout, int) or timeout < 1:
            raise ValueError(
                f"{context}.timeout_seconds must be a positive integer"
            )

        environment = value.get("environment", {})

        if not isinstance(environment, dict):
            raise ValueError(f"{context}.environment must be an object")

        normalized: dict[str, str] = {}

        for key, item in environment.items():
            if not isinstance(key, str) or not key:
                raise ValueError(
                    f"{context}.environment keys must be non-empty strings"
                )

            if not isinstance(item, str):
                raise ValueError(
                    f"{context}.environment[{key!r}] must be a string"
                )

            normalized[key] = item

        return cls(
            argv=tuple(argv),
            timeout_seconds=timeout,
            environment=normalized,
        )


@dataclass(frozen=True)
class EngineDefinition:
    engine_id: str
    description: str
    dependencies: tuple[str, ...]
    required: bool
    commands: dict[str, CommandSpec | None]

    @classmethod
    def from_dict(
        cls,
        engine_id: str,
        value: Any,
    ) -> "EngineDefinition":
        context = f"engines.{engine_id}"

        if not isinstance(value, dict):
            raise ValueError(f"{context} must be an object")

        description = value.get("description", "")

        if not isinstance(description, str):
            raise ValueError(f"{context}.description must be a string")

        dependencies = value.get("dependencies", [])

        if not isinstance(dependencies, list):
            raise ValueError(f"{context}.dependencies must be a list")

        if not all(isinstance(item, str) and item for item in dependencies):
            raise ValueError(
                f"{context}.dependencies entries must be non-empty strings"
            )

        if len(set(dependencies)) != len(dependencies):
            raise ValueError(
                f"{context}.dependencies contains duplicates"
            )

        if engine_id in dependencies:
            raise ValueError(f"{context} cannot depend on itself")

        required = value.get("required", True)

        if not isinstance(required, bool):
            raise ValueError(f"{context}.required must be a boolean")

        raw_commands = value.get("commands", {})

        if not isinstance(raw_commands, dict):
            raise ValueError(f"{context}.commands must be an object")

        unknown = sorted(set(raw_commands) - VALID_ACTIONS)

        if unknown:
            raise ValueError(
                f"{context}.commands has unsupported actions: "
                + ", ".join(unknown)
            )

        commands = {
            action: CommandSpec.from_dict(
                raw_commands.get(action),
                context=f"{context}.commands.{action}",
            )
            for action in sorted(VALID_ACTIONS)
        }

        return cls(
            engine_id=engine_id,
            description=description,
            dependencies=tuple(dependencies),
            required=required,
            commands=commands,
        )
