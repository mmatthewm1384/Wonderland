from __future__ import annotations

from pathlib import Path
from typing import Any

from wlbuilder.context import BuilderContext
from wlbuilder.state import native


def state_path(context: BuilderContext) -> Path:
    return native.path(context)


def read_state(context: BuilderContext) -> dict[str, Any]:
    return native.load(context)


def write_stage_state(context: BuilderContext, stage: str, data: dict[str, str]) -> None:
    state = native.load(context)
    state[stage] = data
    native.save(context, state)
