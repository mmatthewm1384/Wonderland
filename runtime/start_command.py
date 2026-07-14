from __future__ import annotations

import argparse
import json
import sys

from runtime.orchestrator import RuntimeOrchestrator


def symbol(status: str) -> str:
    return {
        "ok": "[✓]",
        "warn": "[!]",
        "failed": "[x]",
        "starting": "[…]",
    }.get(status, "[ ]")


def run_start(args: argparse.Namespace) -> int:
    orchestrator = RuntimeOrchestrator(full=bool(args.full))

    if args.json:
        events = []
        for event in orchestrator.start():
            events.append(event.__dict__)
        print(json.dumps(events, indent=2))
        return 0 if not any(e["status"] == "failed" for e in events) else 1

    print()
    print("WONDERLAND OS")
    print("LOCAL-FIRST • PRIVATE • SECURE • AUTOMATED")
    print()

    failed = False

    for event in orchestrator.start():
        if event.name in {"ready", "failed"}:
            continue

        if args.fast and event.status == "starting":
            continue

        print(f"{symbol(event.status)} {event.name:<24} {event.status.upper():<8} {event.message}")

        if event.status == "failed":
            failed = True

    print()

    if failed:
        print("Wonderland startup failed.")
        return 1

    print("Wonderland runtime ready.")
    return 0


def add_start_arguments(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--fast", action="store_true", help="Use compact startup output.")
    parser.add_argument("--full", action="store_true", help="Start optional platform services too.")
    parser.add_argument("--headless", action="store_true", help="Reserved for non-interactive startup.")
    parser.add_argument("--json", action="store_true", help="Emit machine-readable startup events.")
    parser.add_argument("--no-animation", action="store_true", help="Skip startup animation.")
    parser.add_argument("--fps", type=int, default=20)
    parser.add_argument("--duration", type=float, default=5.0)
    parser.add_argument("--animation", default="vortex")
    parser.add_argument("--theme", default="default")

def main() -> int:
    parser = argparse.ArgumentParser(
        prog="wl start",
        description="Start the Wonderland platform.",
    )
    add_start_arguments(parser)
    args = parser.parse_args()
    return run_start(args)


if __name__ == "__main__":
    raise SystemExit(main())
