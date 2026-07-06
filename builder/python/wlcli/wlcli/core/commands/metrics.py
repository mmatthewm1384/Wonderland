from __future__ import annotations

import json

from wlcli.core.commands.base import CommandSpec
from wlcli.output import CommandResult, ResultLine
from wlcli.runtime.context import RuntimeContext
from wlcli.state.metrics import build_metrics


class MetricsShowCommand:
    spec = CommandSpec(
        name="metrics.show",
        namespace="metrics",
        description="Show runtime metrics",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        data = build_metrics(context.root)

        if data["run_count"] == 0:
            return CommandResult(
                title="Wonderland Runtime Metrics",
                state="WARN",
                message="no runtime history found",
                metadata={"Run": "wl start"},
            )

        lines = [
            ResultLine("PASS", "Runs", str(data["run_count"])),
            ResultLine("PASS", "Pass", str(data["pass_count"])),
            ResultLine("PASS", "Fail", str(data["fail_count"])),
            ResultLine("PASS", "Average", f"{data['average_duration']:.2f}s"),
            ResultLine("PASS", "Fastest", f"{data['fastest_duration']:.2f}s"),
            ResultLine("PASS", "Slowest", f"{data['slowest_duration']:.2f}s"),
        ]

        for sid, item in sorted(data["stages"].items()):
            state = "WARN" if int(item["failure_count"]) else "PASS"
            lines.append(
                ResultLine(
                    state,
                    f"stage:{sid}",
                    f"runs={item['run_count']} avg={item['average_duration']:.2f}s fail={item['failure_count']}",
                )
            )

        state = "WARN" if data["fail_count"] else "PASS"

        return CommandResult(
            title="Wonderland Runtime Metrics",
            state=state,
            message="metrics generated",
            lines=lines,
            metadata={
                "Last success": str(data["last_success"]),
                "Last failure": str(data["last_failure"]),
            },
        )


class MetricsJsonCommand:
    spec = CommandSpec(
        name="metrics.json",
        namespace="metrics",
        description="Show runtime metrics as JSON",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        return CommandResult(
            title="Wonderland Runtime Metrics JSON",
            state="PASS",
            message=json.dumps(build_metrics(context.root), indent=2),
            metadata={"format": "json-payload"},
        )
