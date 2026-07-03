from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class VerifyImageStage:
    name = "verify-image"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Verify boot-critical image contents. Native implementation pending.",
        )
