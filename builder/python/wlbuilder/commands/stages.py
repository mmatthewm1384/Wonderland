from __future__ import annotations

import json
from pathlib import Path

from wlbuilder.context import create_context
from wlbuilder.migration import stage_mode
from wlbuilder.stages import default_pipeline


def run(repo_root: Path, *, as_json: bool = False) -> int:
    context = create_context(repo_root)
    stages = []

    for stage in default_pipeline():
        mode = stage_mode(context, stage.name)
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
            }
        )

    if as_json:
        print(json.dumps({"stages": stages}, indent=2, sort_keys=True))
        return 0

    for stage in stages:
        print(f"{stage['name']}\tmode:{stage['mode']}\timplemented:{str(stage['implemented']).lower()}")

    return 0
