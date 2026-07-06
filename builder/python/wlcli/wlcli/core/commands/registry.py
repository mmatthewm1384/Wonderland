from __future__ import annotations

from wlcli.core.commands.events import (
    EventsClearCommand,
    EventsDoctorCommand,
    EventsMetricsCommand,
    EventsReplayCommand,
    EventsShowCommand,
    EventsTailCommand,
    EventsValidateCommand,
)
from wlcli.core.commands.graph import (
    GraphCleanCommand,
    GraphCurrentCommand,
    GraphDoctorCommand,
    GraphLogsCommand,
    GraphOpenLogCommand,
    GraphStateCommand,
    GraphValidateCommand,
)
from wlcli.core.commands.history import HistoryJsonCommand, HistoryShowCommand
from wlcli.core.commands.lifecycle import (
    LifecycleGraphCommand,
    LifecycleGraphsCommand,
    LifecycleRunCommand,
    LifecycleShowCommand,
)
from wlcli.core.commands.metrics import MetricsJsonCommand, MetricsShowCommand
from wlcli.core.commands.runtime import RuntimeBetaCommand, RuntimeContextCommand, RuntimeStatusCommand

COMMANDS = {
    "events.show": EventsShowCommand(),
    "events.clear": EventsClearCommand(),
    "events.replay": EventsReplayCommand(),
    "events.tail": EventsTailCommand(),
    "events.metrics": EventsMetricsCommand(),
    "events.validate": EventsValidateCommand(),
    "events.doctor": EventsDoctorCommand(),

    "runtime.status": RuntimeStatusCommand(),
    "runtime.beta": RuntimeBetaCommand(),
    "runtime.context": RuntimeContextCommand(),

    "graph.validate": GraphValidateCommand(),
    "graph.current": GraphCurrentCommand(),
    "graph.doctor": GraphDoctorCommand(),
    "graph.state": GraphStateCommand(),
    "graph.logs": GraphLogsCommand(),
    "graph.open-log": GraphOpenLogCommand(),
    "graph.clean": GraphCleanCommand(),

    "lifecycle.show": LifecycleShowCommand(),
    "lifecycle.graphs": LifecycleGraphsCommand(),
    "lifecycle.graph": LifecycleGraphCommand(),
    "lifecycle.run": LifecycleRunCommand(),

    "history.show": HistoryShowCommand(),
    "history.json": HistoryJsonCommand(),

    "metrics.show": MetricsShowCommand(),
    "metrics.json": MetricsJsonCommand(),
}


def get_command(name: str):
    return COMMANDS.get(name)
