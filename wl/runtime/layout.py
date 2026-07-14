"""Layout primitives for Wonderland Runtime."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class TerminalSize:
    width: int
    height: int


@dataclass(frozen=True)
class PlacedLine:
    x: int
    y: int
    text: str


class LayoutEngine:
    def center_x(self, width: int, text: str) -> int:
        return max(0, (width - len(text)) // 2)

    def centered_block(self, width: int, start_y: int, lines: list[str]) -> list[PlacedLine]:
        return [
            PlacedLine(self.center_x(width, line), start_y + index, line)
            for index, line in enumerate(lines)
        ]
