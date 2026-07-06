from __future__ import annotations

import json

from wlcli.core.commands.base import CommandSpec
from wlcli.core.events import EventBus, default_subscribers
from wlcli.core.events.schema import validate_event_shape
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



class EventsTailCommand:
    spec = CommandSpec("events.tail", "events", "Show recent runtime events")

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        limit = 20
        if "--last" in args:
            idx = args.index("--last")
            if idx + 1 < len(args):
                limit = int(args[idx + 1])

        rows = EventBus(context).read(limit=limit)

        lines = [
            ResultLine(
                state="FAIL" if row.get("severity") == "ERROR" else "PASS",
                title=f"{row.get('timestamp')} {row.get('type')}",
                detail=f"{row.get('source')} {row.get('payload')}",
            )
            for row in rows
        ]

        return CommandResult(
            title="Wonderland Runtime Events Tail",
            state="PASS" if rows else "WARN",
            message="events tailed" if rows else "no events found",
            lines=lines,
            payload=rows,
        )



class EventsValidateCommand:
    spec = CommandSpec("events.validate", "events", "Validate runtime event log")

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        rows = EventBus(context).read_all()

        lines: list[ResultLine] = []
        failed = False

        for idx, row in enumerate(rows, start=1):
            errors = validate_event_shape(
                str(row.get("type", "")),
                dict(row.get("payload", {})),
            )

            if errors:
                failed = True
                lines.append(
                    ResultLine(
                        "FAIL",
                        f"event:{idx}",
                        "; ".join(errors),
                    )
                )

        if not rows:
            return CommandResult(
                title="Wonderland Runtime Event Validation",
                state="WARN",
                message="no runtime events found",
                payload={"validated": 0, "errors": 0},
            )

        if not failed:
            lines.append(ResultLine("PASS", f"{len(rows)} event(s) valid"))

        return CommandResult(
            title="Wonderland Runtime Event Validation",
            state="FAIL" if failed else "PASS",
            message="event validation failed" if failed else "event log valid",
            lines=lines,
            payload={
                "validated": len(rows),
                "errors": sum(1 for line in lines if line.state == "FAIL"),
            },
        )



class EventsDoctorCommand:
    spec = CommandSpec("events.doctor", "events", "Run runtime event bus diagnostics")

    def run(self, context: RuntimeContext, args: list[str]) -> CommandResult:
        bus = EventBus(context)
        rows = bus.read_all()

        lines: list[ResultLine] = []
        failed = False
        warned = False

        event_path = context.state_file("runtime-events.jsonl")
        history_path = context.state_file("runtime-history.events.jsonl")
        metrics_path = context.state_file("runtime-metrics.events.json")

        if event_path.exists():
            lines.append(ResultLine("PASS", "Event log", str(event_path)))
        else:
            warned = True
            lines.append(ResultLine("WARN", "Event log", f"missing: {event_path}"))

        if not rows:
            warned = True
            lines.append(ResultLine("WARN", "Events", "no events recorded"))
        else:
            lines.append(ResultLine("PASS", "Events", f"{len(rows)} event(s) recorded"))

        type_counts: dict[str, int] = {}
        severity_counts: dict[str, int] = {}
        schema_counts: dict[str, int] = {}

        validation_errors = 0

        for idx, row in enumerate(rows, start=1):
            event_type = str(row.get("type", ""))
            severity = str(row.get("severity", "UNKNOWN"))
            schema = str(row.get("schema", "unknown"))

            type_counts[event_type] = type_counts.get(event_type, 0) + 1
            severity_counts[severity] = severity_counts.get(severity, 0) + 1
            schema_counts[schema] = schema_counts.get(schema, 0) + 1

            errors = validate_event_shape(event_type, dict(row.get("payload", {})))
            if errors:
                failed = True
                validation_errors += 1
                lines.append(ResultLine("FAIL", f"Invalid event {idx}", "; ".join(errors)))

        if rows and validation_errors == 0:
            lines.append(ResultLine("PASS", "Schema validation", "all events valid"))

        for name, count in sorted(type_counts.items()):
            lines.append(ResultLine("PASS", f"type:{name}", str(count)))

        for name, count in sorted(severity_counts.items()):
            state = "WARN" if name == "ERROR" and count else "PASS"
            if state == "WARN":
                warned = True
            lines.append(ResultLine(state, f"severity:{name}", str(count)))

        for name, count in sorted(schema_counts.items()):
            state = "PASS" if name == "1" else "WARN"
            if state == "WARN":
                warned = True
            lines.append(ResultLine(state, f"schema:{name}", str(count)))

        if history_path.exists():
            lines.append(ResultLine("PASS", "History subscriber artifact", str(history_path)))
        else:
            warned = True
            lines.append(ResultLine("WARN", "History subscriber artifact", f"missing: {history_path}"))

        if metrics_path.exists():
            lines.append(ResultLine("PASS", "Metrics subscriber artifact", str(metrics_path)))
        else:
            warned = True
            lines.append(ResultLine("WARN", "Metrics subscriber artifact", f"missing: {metrics_path}"))

        state = "FAIL" if failed else "WARN" if warned else "PASS"

        return CommandResult(
            title="Wonderland Runtime Event Doctor",
            state=state,
            message="event doctor failed" if failed else "event doctor has warnings" if warned else "event bus healthy",
            lines=lines,
            payload={
                "event_count": len(rows),
                "validation_errors": validation_errors,
                "types": type_counts,
                "severities": severity_counts,
                "schemas": schema_counts,
                "artifacts": {
                    "events": str(event_path),
                    "history": str(history_path),
                    "metrics": str(metrics_path),
                },
            },
        )
