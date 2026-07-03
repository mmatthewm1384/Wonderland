from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class NetworkingStage:
    implemented = False
    description = "Configure SSH, Chrony, Avahi, resolved, and networking."
    legacy_source = "build.__main__ stage 09 Networking"
    name = "networking"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Configure SSH, Chrony, Avahi, resolved, and networking. Native implementation pending.",
        )
