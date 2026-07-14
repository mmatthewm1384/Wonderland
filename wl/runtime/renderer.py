from __future__ import annotations

from typing import Any

from wl.runtime.frame import Align, Box, Frame, Rule, Text


class Renderer:
    """Render canonical Frame objects to a Screen."""

    def __init__(self, screen: Any) -> None:
        self.screen = screen

    def render(self, frame: Frame) -> None:
        if not isinstance(frame, Frame):
            raise TypeError(f"Renderer expected Frame, got {type(frame).__name__}")
        if not hasattr(self.screen, "draw"):
            raise TypeError("screen missing required method: draw")

        if hasattr(self.screen, "clear"):
            self.screen.clear()

        for command in sorted(frame.commands, key=lambda item: item.layer):
            if isinstance(command, Text):
                self._text(command)
            elif isinstance(command, Box):
                self._box(command)
            elif isinstance(command, Rule):
                self._rule(command)

        if hasattr(self.screen, "flush"):
            self.screen.flush()

    def _size(self) -> tuple[int, int]:
        if hasattr(self.screen, "size"):
            size = self.screen.size()
            if isinstance(size, tuple) and len(size) == 2:
                return int(size[0]), int(size[1])
        return 24, 80

    def _text(self, command: Text) -> None:
        _height, width = self._size()
        if command.col is not None:
            col = command.col
        elif command.align == Align.CENTER:
            col = max(0, (width - len(command.text)) // 2)
        elif command.align == Align.RIGHT:
            col = max(0, width - len(command.text))
        else:
            col = 0

        self.screen.draw(command.row, col, command.text)

    def _rule(self, command: Rule) -> None:
        _height, width = self._size()
        rule_width = command.width if command.width is not None else max(0, width - command.col - 1)
        self.screen.draw(command.row, command.col, command.char * rule_width)

    def _box(self, command: Box) -> None:
        row = command.row
        col = command.col
        width = command.width
        height = command.height

        top = "┌" + ("─" * (width - 2)) + "┐"
        if command.title:
            title = command.title[: max(0, width - 4)]
            top = "┌" + title + ("─" * max(0, width - len(title) - 2)) + "┐"

        side = "│" + (" " * (width - 2)) + "│"
        bottom = "└" + ("─" * (width - 2)) + "┘"

        self.screen.draw(row, col, top)
        for offset in range(1, height - 1):
            self.screen.draw(row + offset, col, side)
        self.screen.draw(row + height - 1, col, bottom)
