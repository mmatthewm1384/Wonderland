from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class VerifyImageStage:
    implemented = False
    description = "Verify boot-critical image contents."
    legacy_source = "build.__main__ stage 11 Verify"
    name = "verify-image"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Verify boot-critical image contents. Native implementation pending.",
        )
