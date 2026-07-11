from __future__ import annotations

from wlcli.core.commands.base import CommandSpec
from wlcli.core.lifecycle import LifecycleExecutor, get_graph, list_actions, list_graphs
from wlcli.core.runtime.context import RuntimeContext
from wlcli.output import CommandResult, ResultLine


class LifecycleShowCommand:
    spec = CommandSpec("lifecycle.show", "lifecycle", "Show lifecycle registry")

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        actions = list_actions()
        lines = [
            ResultLine(
                "PASS" if item["status"] == "implemented" else "WARN",
                item["name"],
                f'{item["graph"]}: {item["from_state"]} -> {item["to_state"]} ({item["status"]})',
            )
            for item in actions
        ]

        return CommandResult(
            title="Wonderland Runtime Lifecycle",
            state="PASS",
            message="lifecycle registry loaded",
            lines=lines,
            payload=actions,
        )


class LifecycleGraphsCommand:
    spec = CommandSpec("lifecycle.graphs", "lifecycle", "Show lifecycle graphs")

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        root_bin = str(context.root / "bin")
        payload = list_graphs(root_bin)

        lines = [
            ResultLine(
                "PASS" if graph["stages"] else "WARN",
                graph["name"],
                f'{len(graph["stages"])} stage(s): {graph["description"]}',
            )
            for graph in payload
        ]

        return CommandResult(
            title="Wonderland Lifecycle Graphs",
            state="PASS",
            message="lifecycle graphs loaded",
            lines=lines,
            payload=payload,
        )


class LifecycleGraphCommand:
    spec = CommandSpec("lifecycle.graph", "lifecycle", "Show one lifecycle graph")

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        name = args[0].upper().replace("-", "_") if args else "START"
        graph = get_graph(str(context.root / "bin"), name)

        if graph is None:
            return CommandResult(
                title="Wonderland Lifecycle Graph",
                state="FAIL",
                message=f"unknown lifecycle graph: {name}",
            )

        data = graph.to_dict()

        lines = [
            ResultLine(
                "PASS" if stage["required"] else "WARN",
                stage["id"],
                f'{stage["title"]} deps={stage["depends_on"] or "-"}',
            )
            for stage in data["stages"]
        ]

        return CommandResult(
            title=f"Wonderland Lifecycle Graph: {name}",
            state="PASS" if data["stages"] else "WARN",
            message="lifecycle graph loaded" if data["stages"] else "lifecycle graph planned but empty",
            lines=lines,
            payload=data,
        )



class LifecycleRunCommand:
    spec = CommandSpec("lifecycle.run", "lifecycle", "Execute a lifecycle graph")

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        name = args[0].upper().replace("-", "_") if args else "START"
        graph = get_graph(str(context.root / "bin"), name)

        if graph is None:
            return CommandResult(
                title="Wonderland Lifecycle Run",
                state="FAIL",
                message=f"unknown lifecycle graph: {name}",
            )

        if not graph.stages:
            return CommandResult(
                title=f"Wonderland Lifecycle {name}",
                state="WARN",
                message="lifecycle graph planned but empty",
                payload=graph.to_dict(),
            )

        return LifecycleExecutor(context).execute(graph)
