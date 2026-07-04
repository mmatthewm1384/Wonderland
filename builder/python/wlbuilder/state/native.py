from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from wlbuilder.context import BuilderContext


def path(context: BuilderContext) -> Path:
    return context.repo_root / "builder" / "state" / "native-state.json"


def load(context: BuilderContext) -> dict[str, Any]:
    state_path = path(context)

    if not state_path.exists():
        return {}

    return json.loads(state_path.read_text(encoding="utf-8"))


def save(context: BuilderContext, state: dict[str, Any]) -> None:
    state_path = path(context)
    state_path.parent.mkdir(parents=True, exist_ok=True)

    state_path.write_text(
        json.dumps(state, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
