from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol


class Widget(Protocol):
    def render(self, width: int) -> list[str]:
        ...


@dataclass(frozen=True)
class TextWidget:
    text: str

    def render(self, width: int) -> list[str]:
        return [self.text]
