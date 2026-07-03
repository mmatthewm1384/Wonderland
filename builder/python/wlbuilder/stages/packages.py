from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class PackagesStage:
    name = "packages"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Install kernel, bootloader, SSH, and base packages. Native implementation pending.",
        )
