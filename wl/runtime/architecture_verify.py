from __future__ import annotations

import importlib
import sys
from pathlib import Path


REQUIRED_MODULES = [
    "wl.runtime.launcher",
    "wl.runtime.boot",
    "wl.runtime.boot_ui",
    "wl.runtime.orchestrator",
    "wl.runtime.state",
    "wl.runtime.commands.start",
    "wl.runtime.commands.services",
]

REQUIRED_FILES = [
    "wl/runtime/launcher.py",
    "wl/runtime/boot.py",
    "wl/runtime/boot_ui.py",
    "wl/runtime/orchestrator.py",
    "wl/runtime/commands/start.py",
    "wl/runtime/commands/services.py",
]


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    failed = False

    print("Wonderland Runtime Architecture Verify")
    print()

    for rel in REQUIRED_FILES:
        path = root / rel
        ok = path.exists()
        print(f"{'PASS' if ok else 'FAIL'} file   {rel}")
        failed = failed or not ok

    print()

    for module in REQUIRED_MODULES:
        try:
            importlib.import_module(module)
            print(f"PASS import {module}")
        except Exception as exc:
            failed = True
            print(f"FAIL import {module}: {exc}")

    print()
    print("Result:", "FAIL" if failed else "PASS")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
