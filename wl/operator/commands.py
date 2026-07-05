from __future__ import annotations

from wl.operator.core import OperatorContext
from wl.operator.registry import discover


DEFAULT_COMMANDS = {
    "dashboard": "python3 -m wl.operator.dashboard",
    "scratch": "clear; echo Scratch",
}


def window_commands(context: OperatorContext) -> dict[str, str]:
    commands = dict(DEFAULT_COMMANDS)

    for capability in discover(context):
        commands[capability.window] = f"clear; echo {capability.title}; echo; {capability.command}"

    return commands
