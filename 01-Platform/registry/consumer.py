#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path
from typing import Any


def _load_service_module(root: Path):
    service_path = root / "01-Platform/registry/service.py"
    spec = importlib.util.spec_from_file_location("wl_registry_service", service_path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load registry service: {service_path}")

    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


class RegistryConsumer:
    def __init__(self, root: str | Path | None = None) -> None:
        self.root = Path(root or Path.cwd()).resolve()
        module = _load_service_module(self.root)
        self.service = module.RegistryService(self.root)

    def verify(self) -> bool:
        return self.service.verify() == 0

    def load(self, name: str) -> Any:
        return self.service.load(name)

    def get(self, name: str, key: str | None = None) -> Any:
        return self.service.get(name, key)

    def explain_path(self, path: str) -> dict[str, Any]:
        return self.service.explain_path(path)

    def registry_names(self) -> list[str]:
        return sorted(self.service.list().keys())


def main() -> int:
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd().resolve()
    consumer = RegistryConsumer(root)

    print("Wonderland Registry Consumer Adapter")
    print()
    print("Registries:")
    for name in consumer.registry_names():
        print(f"- {name}")

    print()
    ok = consumer.verify()
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
