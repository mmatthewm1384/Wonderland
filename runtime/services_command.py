from __future__ import annotations

import argparse
import json
import time

from runtime.orchestrator import RuntimeOrchestrator
from runtime.services.base import state_dir
from runtime.services import discover_services


def service_map(full: bool = True):
    services = RuntimeOrchestrator(full=full).services()
    return {service.name: service for service in services}


def print_table(rows: list[tuple[str, str, str, str]]) -> None:
    name_width = max([len("service"), *(len(row[0]) for row in rows)])
    status_width = max([len("status"), *(len(row[1]) for row in rows)])

    print(f"{'service':<{name_width}}  {'status':<{status_width}}  required  message")
    print(f"{'-' * name_width}  {'-' * status_width}  --------  -------")

    for name, status, required, message in rows:
        print(f"{name:<{name_width}}  {status:<{status_width}}  {required:<8}  {message}")


def cmd_list(args: argparse.Namespace) -> int:
    services = RuntimeOrchestrator(full=bool(getattr(args, "full", False))).services()

    if getattr(args, "json", False):
        print(json.dumps([service.metadata() for service in services], indent=2))
        return 0

    rows = [
        (
            service.name,
            "full-only" if service.full_only else "standard",
            "yes" if service.required else "no",
            service.description,
        )
        for service in services
    ]
    print_table(rows)
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    services = RuntimeOrchestrator(full=bool(getattr(args, "full", False))).services()

    if getattr(args, "service", None):
        services = [service for service in services if service.name == getattr(args, "service", None)]
        if not services:
            print(f"unknown service: {args.service}")
            return 2

    health = {service.name: service.health().to_dict() for service in services}

    report = {
        "generated_at": time.time(),
        "full": bool(getattr(args, "full", False)),
        "services": health,
    }
    (state_dir() / "health.json").write_text(json.dumps(report, indent=2) + "\n")

    if getattr(args, "json", False):
        print(json.dumps(health, indent=2))
        return 0

    rows = [
        (
            name,
            data["status"],
            "yes" if next(s.required for s in services if s.name == name) else "no",
            data["message"],
        )
        for name, data in health.items()
    ]

    print_table(rows)
    return 0 if all(data["healthy"] or not next(s.required for s in services if s.name == name) for name, data in health.items()) else 1


def cmd_start(args: argparse.Namespace) -> int:
    services = service_map(full=True)

    service = services.get(args.service)
    if service is None:
        print(f"unknown service: {args.service}")
        return 2

    if service.check():
        print(f"{service.name}: already ready")
        return 0

    if not service.start():
        print(f"{service.name}: start failed")
        return 1

    if service.check():
        print(f"{service.name}: ready")
        return 0

    print(f"{service.name}: start returned but health check failed")
    return 1


def cmd_stop(args: argparse.Namespace) -> int:
    services = service_map(full=True)

    service = services.get(args.service)
    if service is None:
        print(f"unknown service: {args.service}")
        return 2

    if not service.stop():
        print(f"{service.name}: stop failed")
        return 1

    print(f"{service.name}: stopped")
    return 0


def cmd_restart(args: argparse.Namespace) -> int:
    stop_code = cmd_stop(args)
    if stop_code != 0:
        return stop_code
    return cmd_start(args)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="wl services",
        description="Inspect and manage Wonderland runtime services.",
    )

    sub = parser.add_subparsers(dest="command", required=False)

    list_parser = sub.add_parser("list", help="List known runtime services.")
    list_parser.add_argument("--full", action="store_true", help="Include full-only services.")
    list_parser.add_argument("--json", action="store_true")
    list_parser.set_defaults(func=cmd_list)

    status_parser = sub.add_parser("status", help="Show service health.")
    status_parser.add_argument("service", nargs="?")
    status_parser.add_argument("--full", action="store_true", help="Include full-only services.")
    status_parser.add_argument("--json", action="store_true")
    status_parser.set_defaults(func=cmd_status)

    start_parser = sub.add_parser("start", help="Start one service.")
    start_parser.add_argument("service")
    start_parser.set_defaults(func=cmd_start)

    stop_parser = sub.add_parser("stop", help="Stop one service.")
    stop_parser.add_argument("service")
    stop_parser.set_defaults(func=cmd_stop)

    restart_parser = sub.add_parser("restart", help="Restart one service.")
    restart_parser.add_argument("service")
    restart_parser.set_defaults(func=cmd_restart)

    parser.set_defaults(func=cmd_status)
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
