from __future__ import annotations

from dataclasses import dataclass, field
from typing import Protocol


class Renderable(Protocol):
    def render(self, width: int) -> list[str]:
        ...


@dataclass
class Layout:
    gap: int = 1
    items: list[Renderable | str] = field(default_factory=list)

    def add(self, item: Renderable | str) -> None:
        self.items.append(item)

    def render(self, width: int) -> list[str]:
        lines: list[str] = []

        for index, item in enumerate(self.items):
            if index:
                lines.extend([""] * self.gap)

            if isinstance(item, str):
                lines.append(item)
            else:
                lines.extend(item.render(width))

        return lines
