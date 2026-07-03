from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class ConvertStage:
    implemented = False
    description = "Convert raw image into qcow2/vmdk artifacts."
    legacy_source = "build.__main__ stage 13 Convert"
    name = "convert"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Convert raw image into qcow2/vmdk artifacts. Native implementation pending.",
        )
