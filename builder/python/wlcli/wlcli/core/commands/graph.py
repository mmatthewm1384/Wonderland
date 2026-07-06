from __future__ import annotations

from pathlib import Path

from wlcli.core.commands.base import CommandSpec
from wlcli.output import CommandResult, ResultLine
from wlcli.core.runtime.context import RuntimeContext
from wlcli.core.graph import BootGraph
from wlcli.core.report import build_graph_current, graph_state_path


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

        lines = [
            ResultLine("WARN" if "health" in msg else "FAIL", msg)
            for msg in messages
        ]

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

        lines: list[ResultLine] = [
            ResultLine("PASS" if valid else "FAIL", "Boot Graph structure")
        ]

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


class GraphStateCommand:
    spec = CommandSpec(
        name="graph.state",
        namespace="graph",
        description="Show persisted Boot Graph state",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        path = graph_state_path(context.root)

        if not path.exists():
            return CommandResult(
                title="Wonderland Graph State",
                state="FAIL",
                message=f"boot graph state missing: {path}",
                metadata={"Run": "wl start"},
            )

        text = path.read_text(errors="replace")

        return CommandResult(
            title="Wonderland Graph State",
            state="PASS",
            message="state loaded",
            metadata={"Path": str(path)},
            payload=_json_or_text(text),
        )


class GraphLogsCommand:
    spec = CommandSpec(
        name="graph.logs",
        namespace="graph",
        description="List Boot Graph execution logs",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        logs = sorted(
            context.log_dir.glob("wl-stage-*.log"),
            key=lambda p: p.stat().st_mtime,
            reverse=True,
        )

        if not logs:
            return CommandResult(
                title="Wonderland Graph Logs",
                state="WARN",
                message=f"no graph logs found in {context.log_dir}",
            )

        lines = [
            ResultLine(
                "PASS",
                path.name,
                f"{path.stat().st_size} bytes {path}",
            )
            for path in logs[:30]
        ]

        return CommandResult(
            title="Wonderland Graph Logs",
            state="PASS",
            message="graph logs listed",
            lines=lines,
            metadata={"Log dir": str(context.log_dir)},
            payload=[
                {
                    "name": path.name,
                    "path": str(path),
                    "size": path.stat().st_size,
                    "modified": path.stat().st_mtime,
                }
                for path in logs[:30]
            ],
        )


class GraphOpenLogCommand:
    spec = CommandSpec(
        name="graph.open-log",
        namespace="graph",
        description="Print a Boot Graph stage log",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        stage = args[0] if args else ""

        if not stage:
            return CommandResult(
                title="Wonderland Graph Log",
                state="FAIL",
                message="usage: wl graph open-log <stage>",
            )

        candidates = [
            context.log_dir / f"wl-stage-{stage}.log",
            context.log_dir / f"wl-stage-{stage}-health.log",
        ]

        existing = [p for p in candidates if p.exists()]

        if not existing:
            return CommandResult(
                title="Wonderland Graph Log",
                state="WARN",
                message=f"no log found for stage: {stage}",
                lines=[ResultLine("WARN", "searched", str(p)) for p in candidates],
            )

        payload = []
        lines = []

        for path in existing:
            text = path.read_text(errors="replace")
            payload.append({"path": str(path), "content": text})
            lines.append(ResultLine("PASS", path.name, str(path)))

        return CommandResult(
            title="Wonderland Graph Log",
            state="PASS",
            message="log loaded",
            lines=lines,
            payload=payload,
        )


class GraphCleanCommand:
    spec = CommandSpec(
        name="graph.clean",
        namespace="graph",
        description="Remove Boot Graph state and logs",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        removed = []

        state = graph_state_path(context.root)
        if state.exists():
            state.unlink()
            removed.append(str(state))

        for log in context.log_dir.glob("wl-stage-*.log"):
            log.unlink()
            removed.append(str(log))

        return CommandResult(
            title="Wonderland Graph Clean",
            state="PASS",
            message=f"removed {len(removed)} graph artifact(s)",
            lines=[ResultLine("PASS", Path(path).name, path) for path in removed],
            payload={"removed": removed},
        )


def _json_or_text(text: str):
    import json

    try:
        return json.loads(text)
    except Exception:
        return {"content": text}
