from __future__ import annotations

import importlib
import pkgutil

from wl.operator.core import Capability, OperatorContext
import wl.operator.plugins as plugin_package


def discover(context: OperatorContext) -> list[Capability]:
    capabilities: list[Capability] = []

    for module_info in sorted(pkgutil.iter_modules(plugin_package.__path__), key=lambda item: item.name):
        module = importlib.import_module(f"{plugin_package.__name__}.{module_info.name}")
        provider = getattr(module, "capability", None)

        if provider is None:
            continue

        capability = provider(context)

        if not isinstance(capability, Capability):
            raise TypeError(f"Plugin returned invalid capability: {module.__name__}")

        capabilities.append(capability)

    return capabilities
