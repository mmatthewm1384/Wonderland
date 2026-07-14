from __future__ import annotations

CLEAR = "\033[2J\033[H"
RESET = "\033[0m"


def move_home() -> str:
    return "\033[H"


def clear_screen() -> str:
    return CLEAR
