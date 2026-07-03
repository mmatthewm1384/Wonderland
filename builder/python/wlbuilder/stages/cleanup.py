from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class CleanupStage:
    implemented = False
    description = "Unmount filesystems and detach loop devices."
    legacy_source = "build.__main__ stage 12 Cleanup"
    name = "cleanup"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Unmount filesystems and detach loop devices. Native implementation pending.",
        )
