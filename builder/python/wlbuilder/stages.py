from __future__ import annotations

from dataclasses import dataclass

from wlbuilder.context import BuilderContext


@dataclass(frozen=True)
class StageResult:
    name: str
    success: bool


class BuilderStage:
    name = "stage"

    def run(self, context: BuilderContext) -> StageResult:
        raise NotImplementedError
