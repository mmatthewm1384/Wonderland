from __future__ import annotations

from wlcli.core.commands.base import CommandSpec
from wlcli.core.events import EventBus
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
    spec = CommandSpec(
        name="events.show",
        namespace="events",
        description="Show runtime events",
    )

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
    spec = CommandSpec(
        name="events.clear",
        namespace="events",
        description="Clear runtime event log",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        count = EventBus(context).clear()

        return CommandResult(
            title="Wonderland Runtime Events",
            state="PASS",
            message=f"cleared {count} event(s)",
            payload={"cleared": count},
        )
