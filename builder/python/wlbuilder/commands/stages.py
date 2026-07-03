from __future__ import annotations

import json

from wlbuilder.stages import default_pipeline


def run(*, as_json: bool = False) -> int:
    stages = [
        {
            "name": stage.name,
            "implemented": bool(getattr(stage, "implemented", False)),
            "implementation": "native" if getattr(stage, "implemented", False) else "pending",
            "description": getattr(stage, "description", ""),
            "legacy_source": getattr(stage, "legacy_source", ""),
        }
        for stage in default_pipeline()
    ]

    if as_json:
        print(json.dumps({"stages": stages}, indent=2, sort_keys=True))
        return 0

    for stage in stages:
        print(f"{stage['name']}\t{stage['implementation']}")

    return 0
