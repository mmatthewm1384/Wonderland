from __future__ import annotations

import os
from dataclasses import dataclass


@dataclass(frozen=True)
class TerminalSize:
    columns: int
    lines: int


def get_terminal_size(default_columns: int = 80, default_lines: int = 24) -> TerminalSize:
    try:
        size = os.get_terminal_size()
        return TerminalSize(columns=size.columns, lines=size.lines)
    except OSError:
        return TerminalSize(columns=default_columns, lines=default_lines)
