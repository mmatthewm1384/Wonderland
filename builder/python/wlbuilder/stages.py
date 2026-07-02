from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol

from wlbuilder.context import BuilderContext


@dataclass(frozen=True, slots=True)
class StageResult:
    name: str
    success: bool
    message: str = ""


class BuilderStage(Protocol):
    name: str

    def run(self, context: BuilderContext) -> StageResult:
        ...


@dataclass(frozen=True, slots=True)
class LegacyBuildStage:
    name: str = "legacy-build"

    def run(self, context: BuilderContext) -> StageResult:
        return StageResult(
            name=self.name,
            success=True,
            message="Legacy build bridge is active.",
        )


def default_pipeline() -> list[BuilderStage]:
    return [
        LegacyBuildStage(),
    ]
