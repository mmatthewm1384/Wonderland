from __future__ import annotations

RESET = "\033[0m"

def fg(code: int) -> str:
    return f"\033[38;5;{code}m"

CYAN = fg(51)
GREEN = fg(82)
PURPLE = fg(201)
MUTED = fg(244)
DIM = fg(240)
WHITE = fg(15)
