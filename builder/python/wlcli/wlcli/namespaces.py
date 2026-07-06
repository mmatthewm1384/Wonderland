from __future__ import annotations


def normalize_command(command: str, args: list[str]) -> tuple[str, list[str]]:
    if command == "runtime":
        sub = args[0] if args else "status"
        rest = args[1:] if args else []
        return {
            "start": "start",
            "stop": "stop",
            "status": "status",
            "doctor": "doctor",
            "self-test": "self-test",
            "verify-python": "runtime-verify-python",
            "beta": "runtime-beta",
            "beta-verify": "runtime-beta-verify",
            "beta-bootstrap": "runtime-beta-bootstrap",
        }.get(sub, f"runtime-{sub}"), rest

    if command == "graph":
        sub = args[0] if args else "show"
        rest = args[1:] if args else []

        if sub == "export" and "--json" in rest:
            rest = [x for x in rest if x != "--json"]
            return "graph-json", rest

        return {
            "show": "graph",
            "json": "graph-json",
            "export": "graph-json",
            "validate": "graph-validate",
            "doctor": "graph-doctor",
            "current": "graph-current",
            "current-json": "graph-current-json",
            "state": "graph-state",
            "logs": "graph-logs",
            "open-log": "graph-open-log",
            "clean": "graph-clean",
        }.get(sub, f"graph-{sub}"), rest

    if command == "history":
        sub = args[0] if args else "show"
        rest = args[1:] if args else []

        if sub in ("show", "list"):
            return "history-show", rest
        if sub == "failures":
            return "history", ["--failures", *rest]
        if sub in ("json", "export"):
            return "history-json", [x for x in rest if x != "--json"]

        return f"history-{sub}", rest

    if command == "metrics":
        sub = args[0] if args else "show"
        rest = args[1:] if args else []

        if sub in ("show", "summary"):
            return "metrics-show", rest
        if sub in ("json", "export"):
            return "metrics-json", [x for x in rest if x != "--json"]

        return f"metrics-{sub}", rest

    return command, args
