from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol


@dataclass(frozen=True, slots=True)
class StageResultModel:
    name: str
    success: bool
    message: str


class StageModel(Protocol):
    name: str
    implemented: bool
    description: str

    def run(self, context: object) -> StageResultModel:
        ...
