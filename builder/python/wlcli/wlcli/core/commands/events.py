from __future__ import annotations

import json

from wlcli.core.commands.base import CommandSpec
from wlcli.core.events import EventBus, default_subscribers
from wlcli.output import CommandResult, ResultLine
from wlcli.core.runtime.context import RuntimeContext


def _parse(args: list[str]) -> tuple[int, str | None]:
    limit = 50
    event_type = None

    if "--last" in args:
        idx = args.index("--last")
        if idx + 1 < len(args):
            limit = int(args[idx + 1])

    if "--type" in args:
        idx = args.index("--type")
        if idx + 1 < len(args):
            event_type = args[idx + 1]

    return limit, event_type


class EventsShowCommand:
    spec = CommandSpec("events.show", "events", "Show runtime events")

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        limit, event_type = _parse(args)
        rows = EventBus(context).read(limit=limit, event_type=event_type)

        if not rows:
            return CommandResult(
                title="Wonderland Runtime Events",
                state="WARN",
                message="no runtime events found",
                metadata={"Run": "wl start"},
                payload=[],
            )

        lines = [
            ResultLine(
                state="FAIL" if row.get("severity") == "ERROR" else "PASS",
                title=f"{row.get('timestamp')} {row.get('type')}",
                detail=f"{row.get('source')} {row.get('severity')}",
            )
            for row in rows
        ]

        failed = any(line.state == "FAIL" for line in lines)

        return CommandResult(
            title="Wonderland Runtime Events",
            state="FAIL" if failed else "PASS",
            message="events loaded",
            lines=lines,
            metadata={"Limit": str(limit), "Type": event_type or "*"},
            payload=rows,
        )


class EventsClearCommand:
    spec = CommandSpec("events.clear", "events", "Clear runtime event log")

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        count = EventBus(context).clear()
        return CommandResult(
            title="Wonderland Runtime Events",
            state="PASS",
            message=f"cleared {count} event(s)",
            payload={"cleared": count},
        )


class EventsReplayCommand:
    spec = CommandSpec("events.replay", "events", "Replay runtime events through subscribers")

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        count = EventBus(context).replay(default_subscribers())
        return CommandResult(
            title="Wonderland Runtime Events Replay",
            state="PASS",
            message=f"replayed {count} event(s)",
            payload={"replayed": count},
        )


class EventsMetricsCommand:
    spec = CommandSpec("events.metrics", "events", "Show event-derived metrics")

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        path = context.state_file("runtime-metrics.events.json")

        if not path.exists():
            return CommandResult(
                title="Wonderland Event Metrics",
                state="WARN",
                message="event metrics missing",
                metadata={"Run": "wl events replay"},
                payload={},
            )

        data = json.loads(path.read_text())

        lines = [
            ResultLine("PASS", "Events processed", str(data.get("events_processed", 0))),
        ]

        for name, item in sorted(data.get("graphs", {}).items()):
            state = "WARN" if item.get("failed", 0) else "PASS"
            lines.append(ResultLine(state, f"graph:{name}", json.dumps(item, sort_keys=True)))

        for name, item in sorted(data.get("stages", {}).items()):
            state = "WARN" if item.get("failed", 0) else "PASS"
            lines.append(ResultLine(state, f"stage:{name}", json.dumps(item, sort_keys=True)))

        return CommandResult(
            title="Wonderland Event Metrics",
            state="PASS",
            message="event metrics loaded",
            lines=lines,
            payload=data,
        )
