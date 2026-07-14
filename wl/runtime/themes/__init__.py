from __future__ import annotations

from wl.runtime.theme import ThemeManager
from wl.runtime.themes.default import DEFAULT_THEME
from wl.runtime.themes.matrix import MATRIX_THEME
from wl.runtime.themes.minimal import MINIMAL_THEME

THEMES = ThemeManager(
    {
        DEFAULT_THEME.name: DEFAULT_THEME,
        MATRIX_THEME.name: MATRIX_THEME,
        MINIMAL_THEME.name: MINIMAL_THEME,
    },
    default=DEFAULT_THEME.name,
)

__all__ = ["THEMES", "DEFAULT_THEME", "MATRIX_THEME", "MINIMAL_THEME"]
