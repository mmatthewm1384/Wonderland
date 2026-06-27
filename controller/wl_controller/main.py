from __future__ import annotations

import argparse
import json
from pathlib import Path

from wl_controller.api.server import APIServer
from wl_controller.logging.jsonlog import configure_logging
from wl_controller.core.controller import WonderlandController


def main() -> int:
    configure_logging()
    parser = argparse.ArgumentParser(prog="wl-controller-v2")
    parser.add_argument("command", choices=["cycle", "core", "api", "state", "status"])
    parser.add_argument("--root", default=str(Path.home() / "Wonderland"))
    parser.add_argument("--interval", type=int, default=30)
    args = parser.parse_args()

    root = Path(args.root)
    controller = WonderlandController(root)

    if args.command == "cycle":
        print(json.dumps(controller.cycle().to_dict(), indent=2, sort_keys=True))
        return 0

    if args.command == "core":
        controller.run_forever(args.interval)
        return 0

    if args.command == "api":
        APIServer(root).serve()
        return 0

    if args.command == "state":
        print(json.dumps(controller.cycle().to_dict(), indent=2, sort_keys=True))
        return 0

    if args.command == "status":
        state = controller.cycle().to_dict()
        print("Wonderland Platform Status")
        print("")
        print(f"Runtime:       {'PASS' if state['runtime']['running'] else 'FAIL'}")
        print(f"Registry:      {'PASS' if state['registry']['valid'] else 'FAIL'}")
        print(f"Health:        {'PASS' if state['health']['healthy'] else 'WARN'}")
        print(f"Certification: {state['certification']['status']}")
        print(f"Containers:    {state['health']['containers_running']}/{state['health']['containers_total']}")
        return 0

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
