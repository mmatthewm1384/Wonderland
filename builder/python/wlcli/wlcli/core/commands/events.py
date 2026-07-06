from __future__ import annotations

from wlcli.core.commands.base import CommandSpec
from wlcli.core.events import EventBus
from wlcli.output import CommandResult, ResultLine
from wlcli.core.runtime.context import RuntimeContext


class EventsShowCommand:
    spec = CommandSpec(
        name="events.show",
        namespace="events",
        description="Show runtime events",
    )

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        limit = 50
        event_type = None

        if "--last" in args:
            try:
                limit = int(args[args.index("--last") + 1])
            except Exception:
                return CommandResult(
                    title="Wonderland Runtime Events",
                    state="FAIL",
                    message="usage: wl events show --last <count>",
                )

        if "--type" in args:
            try:
                event_type = args[args.index("--type") + 1]
            except Exception:
                return CommandResult(
                    title="Wonderland Runtime Events",
                    state="FAIL",
                    message="usage: wl events show --type <event.type>",
                )

        rows = EventBus(context).read(limit=limit, event_type=event_type)

        if not rows:
            return CommandResult(
                title="Wonderland Runtime Events",
                state="WARN",
                message="no runtime events found",
                metadata={"Run": "wl start"},
            )

        lines = [
            ResultLine(
                state="PASS" if row.get("severity") != "ERROR" else "FAIL",
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
            metadata={"Limit": str(limit), "Type": str(event_type or "*")},
            payload=rows,
        )
