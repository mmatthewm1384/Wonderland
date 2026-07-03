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
    implemented: bool

    def run(self, context: BuilderContext) -> StageResult:
        ...
