from __future__ import annotations

from wlcli.core.commands.base import CommandSpec
from wlcli.output import CommandResult, ResultLine
from wlcli.runtime.context import RuntimeContext
from wlcli.graph import BootGraph
from wlcli.report import build_graph_current


def graph_engine(context: RuntimeContext) -> BootGraph:
    return BootGraph(
        root=context.root,
        log_dir=context.log_dir,
        state_file=context.state_file("wl-boot-graph.json"),
    )


class GraphValidateCommand:
    spec = CommandSpec(
        name="graph.validate",
        namespace="graph",
        description="Validate the START Boot Graph",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        graph = graph_engine(context)
        valid, messages = graph.validate(graph.start_stages())

        lines = []
        for msg in messages:
            state = "WARN" if "health" in msg else "FAIL"
            lines.append(ResultLine(state, msg))

        if valid and not lines:
            lines.append(ResultLine("PASS", "Boot Graph structure valid"))

        return CommandResult(
            title="Wonderland Boot Graph Validation",
            state="PASS" if valid else "FAIL",
            message="boot graph valid" if valid else "boot graph invalid",
            lines=lines,
        )


class GraphCurrentCommand:
    spec = CommandSpec(
        name="graph.current",
        namespace="graph",
        description="Show current persisted Boot Graph state",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        return build_graph_current(context.root)


class GraphDoctorCommand:
    spec = CommandSpec(
        name="graph.doctor",
        namespace="graph",
        description="Run Boot Graph diagnostics",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        graph = graph_engine(context)
        valid, messages = graph.validate(graph.start_stages())
        current = build_graph_current(context.root)

        lines: list[ResultLine] = []

        lines.append(ResultLine("PASS" if valid else "FAIL", "Boot Graph structure"))

        for msg in messages:
            lines.append(ResultLine("WARN" if "health" in msg else "FAIL", msg))

        lines.append(ResultLine(current.state, "Current graph", current.message))

        failed = any(line.state == "FAIL" for line in lines)

        return CommandResult(
            title="Wonderland Graph Doctor",
            state="FAIL" if failed else "PASS",
            message="graph doctor found failures" if failed else "graph doctor passed",
            lines=lines,
        )
