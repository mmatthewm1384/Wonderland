from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class ManifestStage:
    implemented = False
    name = "manifest"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Generate build manifest. Native implementation pending.",
        )
