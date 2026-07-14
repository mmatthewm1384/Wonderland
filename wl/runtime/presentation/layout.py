from __future__ import annotations

import shutil


def terminal_size() -> tuple[int, int]:
    size = shutil.get_terminal_size((100, 32))
    return size.columns, size.lines


def center(text: str, width: int = 72) -> str:
    cols, _ = terminal_size()
    left = max((cols - width) // 2, 0)
    return " " * left + text
