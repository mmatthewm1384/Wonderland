from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages import default_pipeline


VALID_MODES = {"native", "legacy", "skip"}


def _stage_mode(context: BuilderContext, stage_name: str) -> str:
    migration = context.config.data.get("migration", {})

    if not isinstance(migration, dict):
        return "legacy"

    mode = str(migration.get(stage_name, "legacy"))

    if mode not in VALID_MODES:
        return "legacy"

    return mode


def execute(context: BuilderContext) -> int:
    for stage in default_pipeline():
        mode = _stage_mode(context, stage.name)

        if mode == "skip":
            print(f"SKIP stage:{stage.name} mode:skip")
            continue

        if mode == "native" and not getattr(stage, "implemented", False):
            print(f"FAIL stage:{stage.name} mode:native reason:not-implemented")
            return 1

        result = stage.run(context)
        status = "PASS" if result.success else "FAIL"
        implementation = "native" if mode == "native" else "legacy"
        detail = f": {result.message}" if result.message else ""

        print(f"{status} stage:{result.name} mode:{mode} implementation:{implementation}{detail}")

        if not result.success:
            return 1

    return 0
