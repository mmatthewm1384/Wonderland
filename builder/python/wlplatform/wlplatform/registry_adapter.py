from __future__ import annotations

import importlib
import inspect
import json
import subprocess
import sys
import time
from collections.abc import Mapping, Sequence
from pathlib import Path
from types import ModuleType
from typing import Any

from .context import PlatformContext
from .result import CheckResult, Status


class RegistryAdapterError(RuntimeError):
    pass


PUBLIC_REQUIRED_COMMANDS = frozenset(
    {
        "architecture",
        "builder",
        "governance",
        "runtime",
    }
)


def _install_python_paths(root: Path) -> None:
    candidates = (
        root / "builder/python/wlcli",
        root / "builder/python",
        root,
    )

    for candidate in reversed(candidates):
        if not candidate.is_dir():
            continue

        value = str(candidate)

        if value not in sys.path:
            sys.path.insert(0, value)


def _import_registry_module() -> ModuleType:
    candidates = (
        "wlcli.core.commands.registry",
        "wlcli.registry",
    )
    failures: list[str] = []

    for name in candidates:
        try:
            return importlib.import_module(name)
        except Exception as exc:
            failures.append(
                f"{name}: {type(exc).__name__}: {exc}"
            )

    raise RegistryAdapterError(
        "unable to import wlcli registry: "
        + "; ".join(failures)
    )


def _command_name(value: Any) -> str | None:
    if isinstance(value, str):
        return value.strip() or None

    if isinstance(value, Mapping):
        for key in ("name", "command", "id"):
            candidate = value.get(key)

            if isinstance(candidate, str) and candidate.strip():
                return candidate.strip()

    for attribute in ("name", "command", "id"):
        candidate = getattr(value, attribute, None)

        if isinstance(candidate, str) and candidate.strip():
            return candidate.strip()

    return None


def _extract_from_mapping(
    value: Mapping[Any, Any],
) -> set[str]:
    commands: set[str] = set()

    for key, item in value.items():
        if isinstance(key, str) and key.strip():
            commands.add(key.strip())

        item_name = _command_name(item)

        if item_name:
            commands.add(item_name)

    return commands


def _extract_from_sequence(
    value: Sequence[Any],
) -> set[str]:
    commands: set[str] = set()

    for item in value:
        item_name = _command_name(item)

        if item_name:
            commands.add(item_name)

    return commands


def _extract_commands(value: Any) -> set[str]:
    if isinstance(value, Mapping):
        return _extract_from_mapping(value)

    if isinstance(value, Sequence) and not isinstance(
        value,
        (str, bytes, bytearray),
    ):
        return _extract_from_sequence(value)

    return set()


def _safe_zero_arg_call(value: Any) -> Any:
    if not callable(value):
        return None

    try:
        signature = inspect.signature(value)
    except (TypeError, ValueError):
        return None

    required = [
        parameter
        for parameter in signature.parameters.values()
        if parameter.default is inspect.Parameter.empty
        and parameter.kind
        in {
            inspect.Parameter.POSITIONAL_ONLY,
            inspect.Parameter.POSITIONAL_OR_KEYWORD,
            inspect.Parameter.KEYWORD_ONLY,
        }
    ]

    if required:
        return None

    return value()


def _discover_internal_commands(
    module: ModuleType,
) -> tuple[set[str], str]:
    """
    Discover the command collection owned by the imported wlcli module.

    This collection validates the internal Registry Engine. It is not assumed
    to be the complete public CLI registry because shell-delegated namespaces
    such as Builder or Governance may be registered at a higher layer.
    """
    attribute_candidates = (
        "COMMANDS",
        "REGISTRY",
        "COMMAND_REGISTRY",
        "commands",
        "registry",
    )

    for attribute in attribute_candidates:
        if not hasattr(module, attribute):
            continue

        value = getattr(module, attribute)

        try:
            resolved = _safe_zero_arg_call(value)
        except Exception:
            resolved = None

        if resolved is not None:
            value = resolved

        commands = _extract_commands(value)

        if commands:
            return commands, f"attribute:{attribute}"

    function_candidates = (
        "list_commands",
        "get_commands",
        "command_registry",
        "get_registry",
        "build_registry",
    )

    for function_name in function_candidates:
        function = getattr(module, function_name, None)

        try:
            value = _safe_zero_arg_call(function)
        except Exception:
            continue

        commands = _extract_commands(value)

        if commands:
            return commands, f"function:{function_name}"

    raise RegistryAdapterError(
        "registry module imported but exposed no discoverable "
        "internal command collection"
    )


def _public_commands_json(
    context: PlatformContext,
) -> tuple[set[str], str]:
    """
    Load the canonical public CLI projection.

    The public registry includes Python-native commands and delegated subsystem
    namespaces exposed by bin/wl.
    """
    completed = subprocess.run(
        [str(context.root / "bin/wl"), "commands-json"],
        cwd=context.root,
        env=context.environment(),
        stdin=subprocess.DEVNULL,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        timeout=60,
        check=False,
    )

    if completed.returncode != 0:
        raise RegistryAdapterError(
            f"commands-json exited {completed.returncode}: "
            f"{completed.stderr.strip()}"
        )

    try:
        payload = json.loads(completed.stdout)
    except json.JSONDecodeError as exc:
        raise RegistryAdapterError(
            f"commands-json emitted invalid JSON: {exc}"
        ) from exc

    commands = _extract_commands(payload)

    if not commands and isinstance(payload, Mapping):
        metadata = {
            "schema_version",
            "version",
            "generated_at",
            "result",
            "status",
            "categories",
        }

        commands = {
            str(key)
            for key in payload
            if key not in metadata
        }

    # Some command renderers group entries under categories.
    if isinstance(payload, Mapping):
        categories = payload.get("categories")

        if isinstance(categories, Mapping):
            for category_value in categories.values():
                commands.update(
                    _extract_commands(category_value)
                )

        for value in payload.values():
            if isinstance(value, Mapping):
                commands.update(
                    _extract_commands(value)
                )
            elif isinstance(value, Sequence) and not isinstance(
                value,
                (str, bytes, bytearray),
            ):
                commands.update(
                    _extract_commands(value)
                )

    commands = {
        command.strip()
        for command in commands
        if isinstance(command, str) and command.strip()
    }

    if not commands:
        raise RegistryAdapterError(
            "commands-json returned an empty public registry"
        )

    return commands, "commands-json"


def verify_registry(
    context: PlatformContext,
) -> CheckResult:
    started = time.monotonic()

    try:
        _install_python_paths(context.root)

        module = _import_registry_module()
        internal_commands, internal_source = (
            _discover_internal_commands(module)
        )

        if not internal_commands:
            raise RegistryAdapterError(
                "internal command registry is empty"
            )

        public_commands, public_source = (
            _public_commands_json(context)
        )
    except Exception as exc:
        return CheckResult(
            name="registry",
            status=Status.FAIL,
            summary=f"registry verification failed: {exc}",
            duration_ms=round(
                (time.monotonic() - started) * 1000
            ),
            details={
                "exception_type": type(exc).__name__,
            },
        )

    missing_public = sorted(
        PUBLIC_REQUIRED_COMMANDS - public_commands
    )

    if missing_public:
        return CheckResult(
            name="registry",
            status=Status.FAIL,
            summary=(
                "public command registry missing required commands: "
                + ", ".join(missing_public)
            ),
            duration_ms=round(
                (time.monotonic() - started) * 1000
            ),
            details={
                "internal_source": internal_source,
                "internal_command_count": len(
                    internal_commands
                ),
                "public_source": public_source,
                "public_command_count": len(
                    public_commands
                ),
                "missing_public": missing_public,
            },
        )

    return CheckResult(
        name="registry",
        status=Status.PASS,
        summary=(
            f"{len(internal_commands)} internal and "
            f"{len(public_commands)} public commands registered"
        ),
        duration_ms=round(
            (time.monotonic() - started) * 1000
        ),
        details={
            "mode": "hybrid",
            "internal_source": internal_source,
            "internal_command_count": len(
                internal_commands
            ),
            "public_source": public_source,
            "public_command_count": len(
                public_commands
            ),
            "required_public_commands": sorted(
                PUBLIC_REQUIRED_COMMANDS
            ),
        },
    )
