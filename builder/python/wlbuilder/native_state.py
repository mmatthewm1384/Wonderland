from __future__ import annotations

import json
from pathlib import Path

from wlbuilder.context import BuilderContext


def state_path(context: BuilderContext) -> Path:
    return context.tmp_root / "native-stages.json"


def write_stage_state(context: BuilderContext, stage: str, data: dict[str, str]) -> None:
    path = state_path(context)
    path.parent.mkdir(parents=True, exist_ok=True)

    state = {}
    if path.exists():
        state = json.loads(path.read_text(encoding="utf-8"))

    state[stage] = data
    path.write_text(json.dumps(state, indent=2, sort_keys=True), encoding="utf-8")
