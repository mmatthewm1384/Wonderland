from __future__ import annotations

import importlib


MODULES = (
    "wl.runtime.launcher",
    "wl.runtime.boot",
    "wl.runtime.boot_ui",
    "wl.runtime.orchestrator",
    "wl.runtime.state",
    "wl.runtime.commands.start",
    "wl.runtime.commands.services",
)


def main() -> int:
    for module in MODULES:
        importlib.import_module(module)
        print(f"PASS import {module}")
    print("PASS runtime phase2 import verify")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
