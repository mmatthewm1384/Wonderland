from __future__ import annotations

import shutil
import sys
from typing import TextIO


class Screen:
    """Terminal screen abstraction.

    Screen owns terminal IO and ANSI escape sequences. Renderer and Scene code
    must not emit raw terminal control codes.
    """

    def __init__(self, stream: TextIO | None = None) -> None:
        self.stream = stream or sys.stdout

    def enter(self, *, alternate_screen: bool = True) -> None:
        if alternate_screen:
            self.stream.write("\x1b[?1049h")
        self.stream.write("\x1b[?25l")
        self.flush()

    def exit(self, *, alternate_screen: bool = True) -> None:
        self.stream.write("\x1b[?25h")
        if alternate_screen:
            self.stream.write("\x1b[?1049l")
        self.flush()

    def clear(self) -> None:
        self.stream.write("\x1b[2J\x1b[H")

    def size(self) -> tuple[int, int]:
        terminal = shutil.get_terminal_size(fallback=(80, 24))
        return terminal.lines, terminal.columns

    def draw(self, row: int, col: int, text: str) -> None:
        safe_row = max(0, int(row))
        safe_col = max(0, int(col))
        self.stream.write(f"\x1b[{safe_row + 1};{safe_col + 1}H{text}")

    def flush(self) -> None:
        self.stream.flush()
