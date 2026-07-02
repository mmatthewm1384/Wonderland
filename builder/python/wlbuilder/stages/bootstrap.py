from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stage_types import StageResult


class BootstrapStage:
    name = "bootstrap"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(self.name, True)
