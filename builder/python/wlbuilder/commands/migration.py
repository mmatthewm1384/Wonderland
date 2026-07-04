from __future__ import annotations

import json

from wlbuilder.migration import stage_mode
from wlbuilder.runtime_context import RuntimeContext
from wlbuilder.stages import default_pipeline


def run(context: RuntimeContext) -> int:
    builder = context.builder

    items = []
    for stage in default_pipeline():
        mode = stage_mode(builder, stage.name)
        implemented = bool(getattr(stage, "implemented", False))
        items.append(
            {
                "stage": stage.name,
                "mode": mode,
                "implemented": implemented,
                "ready": mode != "native" or implemented,
            }
        )

    if context.as_json:
        print(json.dumps({"migration": items}, indent=2, sort_keys=True))
        return 0

    for item in items:
        print(
            f"{item['stage']}\t"
            f"mode:{item['mode']}\t"
            f"implemented:{str(item['implemented']).lower()}\t"
            f"ready:{str(item['ready']).lower()}"
        )

    return 0
