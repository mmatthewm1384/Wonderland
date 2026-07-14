from __future__ import annotations

import json
import platform
import sys

from wl.runtime.rootless_state import read_rootless_json
from wl.runtime.state import RuntimeState


REPORTS = [
    "startup.json",
    "health.json",
    "services.json",
    "graph.json",
]


def read_report(name: str) -> dict:
    if platform.system() == "Darwin":
        return read_rootless_json(name)
    return RuntimeState().read_json(name)


def main() -> int:
    ok = True
    data = {}

    for name in REPORTS:
        try:
            data[name.removesuffix(".json")] = read_report(name)
        except Exception as exc:
            ok = False
            data[name.removesuffix(".json")] = {
                "ok": False,
                "error": str(exc),
            }

    print(json.dumps(data, indent=2))
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
