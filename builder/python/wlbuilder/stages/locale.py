from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class LocaleStage:
    implemented = False
    description = "Configure UTF-8 locale."
    legacy_source = "build.__main__ stage 07 Locale"
    name = "locale"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Configure UTF-8 locale. Native implementation pending.",
        )
