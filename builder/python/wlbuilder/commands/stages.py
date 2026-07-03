from __future__ import annotations

import json
from pathlib import Path

from wlbuilder.config import load_config
from wlbuilder.stages import default_pipeline


def _mode(config_data: dict, stage_name: str) -> str:
    migration = config_data.get("migration", {})
    if not isinstance(migration, dict):
        return "legacy"

    mode = str(migration.get(stage_name, "legacy"))
    return mode if mode in {"native", "legacy", "skip"} else "legacy"


def run(repo_root: Path, *, as_json: bool = False) -> int:
    config = load_config(repo_root)
    stages = []

    for stage in default_pipeline():
        mode = _mode(config.data, stage.name)
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
