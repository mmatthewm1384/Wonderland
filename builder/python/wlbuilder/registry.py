from __future__ import annotations

from collections.abc import Callable
from dataclasses import dataclass


@dataclass(frozen=True)
class CommandSpec:
    name: str
    module: str
    help: str


COMMAND_SPECS: tuple[CommandSpec, ...] = (
    CommandSpec("status", "wlbuilder.commands.status", "Show builder runtime status"),
    CommandSpec("doctor", "wlbuilder.commands.doctor", "Run builder runtime diagnostics"),
    CommandSpec("verify", "wlbuilder.commands.verify", "Verify builder runtime contract"),
    CommandSpec("artifacts", "wlbuilder.commands.artifacts", "List Builder v2 artifacts"),
    CommandSpec("stages", "wlbuilder.commands.stages", "List Builder v2 stages"),
    CommandSpec("docs", "wlbuilder.commands.docs", "Generate Builder v2 documentation"),
    CommandSpec("hygiene", "wlbuilder.commands.hygiene", "Check or restore generated repository state"),
    CommandSpec("native-state", "wlbuilder.commands.native_state", "Show native Builder v2 stage state"),
    CommandSpec("build", "wlbuilder.commands.build", "Build a Wonderland OS image"),
)


def load_commands() -> dict[str, Callable[..., int]]:
    import importlib

    commands: dict[str, Callable[..., int]] = {}

    for spec in COMMAND_SPECS:
        module = importlib.import_module(spec.module)
        commands[spec.name] = module.run

    return commands
