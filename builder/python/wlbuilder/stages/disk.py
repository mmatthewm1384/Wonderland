from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class DiskStage:
    implemented = False
    description = "Create raw disk image and partition layout."
    legacy_source = "build.__main__ stage 02 Disk"
    name = "disk"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Create raw disk image and partition layout. Native implementation pending.",
        )
