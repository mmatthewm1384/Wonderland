from __future__ import annotations

import json

from wlbuilder.migration import stage_mode
from wlbuilder.runtime_context import RuntimeContext
from wlbuilder.stages import default_pipeline


def run(context: RuntimeContext) -> int:
    builder = context.builder
    stages = []

    for stage in default_pipeline():
        mode = stage_mode(builder, stage.name)
        implemented = bool(getattr(stage, "implemented", False))

        stages.append(
            {
                "name": stage.name,
                "mode": mode,
                "implemented": implemented,
                "ready": mode != "native" or implemented,
                "implementation": "native" if mode == "native" else mode,
                "description": getattr(stage, "description", ""),
                "legacy_source": getattr(stage, "legacy_source", ""),
                "requires": list(getattr(stage, "requires", ())),
                "produces": list(getattr(stage, "produces", ())),
            }
        )

    if context.as_json:
        print(json.dumps({"stages": stages}, indent=2, sort_keys=True))
        return 0

    for stage in stages:
        print(
            f"{stage['name']}\t"
            f"mode:{stage['mode']}\t"
            f"implemented:{str(stage['implemented']).lower()}"
        )

    return 0
