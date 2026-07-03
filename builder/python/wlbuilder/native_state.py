from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from wlbuilder.context import BuilderContext


def state_path(context: BuilderContext) -> Path:
    return context.tmp_root / "native-stages.json"


def read_state(context: BuilderContext) -> dict[str, Any]:
    path = state_path(context)

    if not path.exists():
        return {}

    data = json.loads(path.read_text(encoding="utf-8"))

    if not isinstance(data, dict):
        raise ValueError(f"invalid native stage state: {path}")

    return data


def write_stage_state(context: BuilderContext, stage: str, data: dict[str, str]) -> None:
    path = state_path(context)
    path.parent.mkdir(parents=True, exist_ok=True)

    state = read_state(context)
    state[stage] = data

    path.write_text(json.dumps(state, indent=2, sort_keys=True), encoding="utf-8")
