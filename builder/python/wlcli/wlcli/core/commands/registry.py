from __future__ import annotations

from wlcli.core.commands.graph import (
    GraphCurrentCommand,
    GraphDoctorCommand,
    GraphValidateCommand,
)
from wlcli.core.commands.runtime import RuntimeBetaCommand, RuntimeStatusCommand

COMMANDS = {
    "runtime.status": RuntimeStatusCommand(),
    "runtime.beta": RuntimeBetaCommand(),
    "graph.validate": GraphValidateCommand(),
    "graph.current": GraphCurrentCommand(),
    "graph.doctor": GraphDoctorCommand(),
}


def get_command(name: str):
    return COMMANDS.get(name)
