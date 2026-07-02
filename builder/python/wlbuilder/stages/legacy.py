from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stage_types import StageResult


class LegacyBuildStage:
    name = "legacy-build"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Legacy build bridge remains active.",
        )
