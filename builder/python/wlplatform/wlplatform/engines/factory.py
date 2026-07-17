from __future__ import annotations

import importlib

from .catalog import ENGINE_CATALOG


def get_engine(name, root):

    if name not in ENGINE_CATALOG:
        raise ValueError(
            f"Unknown engine: {name}"
        )

    spec = ENGINE_CATALOG[name]

    module = importlib.import_module(
        spec["module"],
        package="wlplatform.engines",
    )

    cls = getattr(
        module,
        spec["class"],
    )

    return cls(root)
