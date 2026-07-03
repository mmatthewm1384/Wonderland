from __future__ import annotations

from wlbuilder.config_schema import VALID_MIGRATION_MODES
from wlbuilder.context import BuilderContext


def stage_mode(context: BuilderContext, stage_name: str) -> str:
    migration = context.config.data.get("migration", {})

    if not isinstance(migration, dict):
        return "legacy"

    mode = str(migration.get(stage_name, "legacy"))
    return mode if mode in VALID_MIGRATION_MODES else "legacy"


def is_native_enabled(context: BuilderContext, stage_name: str) -> bool:
    return stage_mode(context, stage_name) == "native"
