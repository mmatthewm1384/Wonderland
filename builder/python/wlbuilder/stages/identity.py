from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class IdentityStage:
    implemented = False
    description = "Configure hostname, branding, os-release, and MOTD."
    legacy_source = "build.__main__ stage 06 Identity"
    name = "identity"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Configure hostname, branding, os-release, and MOTD. Native implementation pending.",
        )
