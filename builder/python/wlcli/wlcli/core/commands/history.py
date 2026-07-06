from __future__ import annotations

from wlcli.core.commands.base import CommandSpec
from wlcli.output import CommandResult, ResultLine
from wlcli.runtime.context import RuntimeContext
from wlcli.core.state.history import read_history


def _parse_args(args: list[str]) -> tuple[int, bool]:
    limit = 20
    failures_only = "--failures" in args

    if "--last" in args:
        idx = args.index("--last")
        if idx + 1 < len(args):
            limit = int(args[idx + 1])

    return limit, failures_only


class HistoryShowCommand:
    spec = CommandSpec(
        name="history.show",
        namespace="history",
        description="Show runtime history",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        limit, failures_only = _parse_args(args)
        rows = read_history(context.root, limit=limit, failures_only=failures_only)

        if not rows:
            return CommandResult(
                title="Wonderland Runtime History",
                state="WARN",
                message="no runtime history found",
                metadata={"Run": "wl start"},
            )

        lines = []
        for row in rows:
            result = row.get("result", "UNKNOWN")
            title = f"{row.get('timestamp', 'unknown')} {row.get('command', 'unknown')} {row.get('graph', 'unknown')}"
            lines.append(
                ResultLine(
                    state=result,
                    title=title,
                    duration=float(row.get("duration", 0.0)),
                )
            )

        failed = any(line.state == "FAIL" for line in lines)

        return CommandResult(
            title="Wonderland Runtime History",
            state="FAIL" if failed and failures_only else "PASS",
            message="history loaded",
            lines=lines,
            metadata={"Limit": str(limit), "Failures only": str(failures_only)},
        )


class HistoryJsonCommand:
    spec = CommandSpec(
        name="history.json",
        namespace="history",
        description="Show runtime history as JSON",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        limit, failures_only = _parse_args(args)
        rows = read_history(context.root, limit=limit, failures_only=failures_only)

        return CommandResult(
            title="Wonderland Runtime History JSON",
            state="PASS",
            payload=rows,
            metadata={"format": "json-payload"},
        )
