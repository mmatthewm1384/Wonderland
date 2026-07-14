#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[2]
CONSUMER = ROOT / "01-Platform/registry/consumer.py"


def load_consumer():
    spec = importlib.util.spec_from_file_location("wl_registry_consumer", CONSUMER)
    if spec is None or spec.loader is None:
        raise RuntimeError("cannot load consumer adapter")

    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module.RegistryConsumer(ROOT)


def main() -> int:
    consumer = load_consumer()

    ownership = consumer.load("ownership")
    classification = consumer.load("classification")
    builders = consumer.load("builders")

    assert "01-Platform" in ownership
    assert "classifications" in classification
    assert "builders" in builders

    explained = consumer.explain_path("builder/python")
    assert explained["top_level"] == "builder"

    print("PASS registry consumer adapter smoke test")
    print("RESULT PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
