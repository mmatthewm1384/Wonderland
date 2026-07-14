from __future__ import annotations

import json
import platform

from wl.runtime.rootless_state import read_rootless_json
from wl.runtime.state import RuntimeState


def read_health() -> dict:
    if platform.system() == "Darwin":
        return read_rootless_json("health.json")
    return RuntimeState().read_json("health.json")


def main() -> int:
    try:
        health = read_health()
    except Exception as exc:
        print(f"Runtime status unavailable: {exc}")
        return 1

    services = health.get("services", {})
    if not services:
        print("Runtime status unavailable: no service health data")
        return 1

    print("Wonderland Runtime Status")
    print()

    failed = 0

    for name, data in services.items():
        healthy = bool(data.get("healthy"))
        status = data.get("status", "unknown")
        message = data.get("message", "")

        marker = "✓" if healthy else "!"
        if not healthy:
            failed += 1

        print(f"[{marker}] {name:<24} {status:<12} {message}")

    print()
    print(f"Services: {len(services)}")
    print(f"Unhealthy: {failed}")

    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
