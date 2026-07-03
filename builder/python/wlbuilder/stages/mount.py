from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class MountStage:
    implemented = False
    name = "mount"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Attach image, mount filesystems, and prepare chroot. Native implementation pending.",
        )
