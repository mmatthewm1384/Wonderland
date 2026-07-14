from __future__ import annotations

from wl.runtime.theme import Theme

MINIMAL_THEME = Theme(
    name="minimal",
    colors={
        "body": "",
        "header": "\033[1m",
        "muted": "\033[2m",
        "success": "",
        "warning": "",
        "error": "",
        "panel": "",
    },
    glyphs={
        "hline": "-",
        "vline": "|",
        "tl": "+",
        "tr": "+",
        "bl": "+",
        "br": "+",
    },
    spacing={"margin": 2, "gutter": 2},
)
