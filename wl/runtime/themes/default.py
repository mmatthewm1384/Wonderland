from __future__ import annotations

from wl.runtime.theme import Theme

DEFAULT_THEME = Theme(
    name="default",
    colors={
        "body": "\033[37m",
        "header": "\033[1;37m",
        "muted": "\033[2;37m",
        "success": "\033[32m",
        "warning": "\033[33m",
        "error": "\033[31m",
        "panel": "\033[37m",
    },
    glyphs={
        "hline": "─",
        "vline": "│",
        "tl": "┌",
        "tr": "┐",
        "bl": "└",
        "br": "┘",
    },
    spacing={"margin": 2, "gutter": 2},
)
