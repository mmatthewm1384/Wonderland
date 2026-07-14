#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
CONSUMER = ROOT / "01-Platform/registry/consumer.py"

REQUIRED_KEYS = {
    "legacy_path",
    "constitutional_area",
    "target",
    "owner",
    "purpose",
    "outputs",
    "state",
}


def load_registry_consumer(root: Path):
    spec = importlib.util.spec_from_file_location("wl_registry_consumer", CONSUMER)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load registry consumer: {CONSUMER}")

    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module.RegistryConsumer(root)


def fail_line(message: str) -> None:
    print(f"FAIL {message}")


def pass_line(message: str) -> None:
    print(f"PASS {message}")


def info_line(message: str) -> None:
    print(f"INFO {message}")


def warn_line(message: str) -> None:
    print(f"WARN {message}")


def validate_builder(name: str, item: dict[str, Any]) -> int:
    failures = 0

    missing = sorted(REQUIRED_KEYS - set(item))
    if missing:
        fail_line(f"builder {name} missing keys: {', '.join(missing)}")
        return 1

    legacy = ROOT / item["legacy_path"]
    area = ROOT / item["constitutional_area"]

    if legacy.exists():
        pass_line(f"builder {name} legacy path present: {item['legacy_path']}")
    else:
        warn_line(f"builder {name} legacy path missing: {item['legacy_path']}")

    if area.exists():
        pass_line(f"builder {name} constitutional area: {item['constitutional_area']}")
    else:
        fail_line(f"builder {name} constitutional area missing: {item['constitutional_area']}")
        failures += 1

    if not isinstance(item.get("outputs"), list):
        fail_line(f"builder {name} outputs must be a list")
        failures += 1
    else:
        for output in item["outputs"]:
            info_line(f"builder {name} output: {output}")

    info_line(f"builder {name} target: {item['target']}")
    info_line(f"builder {name} owner: {item['owner']}")
    info_line(f"builder {name} state: {item['state']}")

    return failures


def main() -> int:
    consumer = load_registry_consumer(ROOT)

    if not consumer.verify():
        fail_line("registry consumer verification failed")
        print("RESULT FAIL")
        return 1

    data = consumer.load("builders")
    builders = data.get("builders", {})

    if not builders:
        fail_line("no builders registered")
        print("RESULT FAIL")
        return 1

    failures = 0

    for name, item in sorted(builders.items()):
        failures += validate_builder(name, item)

    if failures:
        print("RESULT FAIL")
        return 1

    pass_line("builder ownership registry verified through registry consumer")
    print("RESULT PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
