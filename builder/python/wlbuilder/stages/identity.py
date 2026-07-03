from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class IdentityStage:
    name = "identity"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Configure hostname, branding, os-release, and MOTD. Native implementation pending.",
        )
