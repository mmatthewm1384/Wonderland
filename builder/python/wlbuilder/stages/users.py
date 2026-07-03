from __future__ import annotations

from wlbuilder.context import BuilderContext
from wlbuilder.stages.base import StageResult


class UsersStage:
    implemented = False
    name = "users"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Create default user and sudo policy. Native implementation pending.",
        )
