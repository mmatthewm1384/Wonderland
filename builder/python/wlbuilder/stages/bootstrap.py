from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class BootstrapStage:
    implemented = False
    description = "Install Debian base system."
    legacy_source = "build.__main__ stage 04 Bootstrap"
    name = "bootstrap"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Install Debian base system. Native implementation pending.",
        )
