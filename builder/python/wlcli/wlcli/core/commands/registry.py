from __future__ import annotations

from wlcli.core.commands.runtime import RuntimeBetaCommand, RuntimeStatusCommand

COMMANDS = {
    "runtime.status": RuntimeStatusCommand(),
    "runtime.beta": RuntimeBetaCommand(),
}


def get_command(name: str):
    return COMMANDS.get(name)
