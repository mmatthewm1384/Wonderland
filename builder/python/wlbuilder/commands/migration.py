from __future__ import annotations

import json
from pathlib import Path

from wlbuilder.context import create_context
from wlbuilder.migration import stage_mode
from wlbuilder.stages import default_pipeline


def run(repo_root: Path, *, as_json: bool = False) -> int:
    context = create_context(repo_root)

    items = []
    for stage in default_pipeline():
        mode = stage_mode(context, stage.name)
        implemented = bool(getattr(stage, "implemented", False))
        items.append(
            {
                "stage": stage.name,
                "mode": mode,
                "implemented": implemented,
                "ready": mode != "native" or implemented,
            }
        )

    if as_json:
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
