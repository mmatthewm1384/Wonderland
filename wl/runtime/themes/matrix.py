from __future__ import annotations

from wl.runtime.theme import Theme

MATRIX_THEME = Theme(
    name="matrix",
    colors={
        "body": "\033[32m",
        "header": "\033[1;32m",
        "muted": "\033[2;32m",
        "success": "\033[92m",
        "warning": "\033[33m",
        "error": "\033[31m",
        "panel": "\033[32m",
    },
    glyphs={
        "hline": "═",
        "vline": "║",
        "tl": "╔",
        "tr": "╗",
        "bl": "╚",
        "br": "╝",
    },
    spacing={"margin": 2, "gutter": 2},
)
