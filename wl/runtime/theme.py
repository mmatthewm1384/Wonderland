from __future__ import annotations

from dataclasses import dataclass
from typing import Mapping


@dataclass(frozen=True, slots=True)
class Theme:
    name: str
    colors: Mapping[str, str]
    glyphs: Mapping[str, str]
    spacing: Mapping[str, int]

    def color(self, role: str) -> str:
        return self.colors.get(role, self.colors.get("body", ""))

    def glyph(self, name: str, default: str = "") -> str:
        return self.glyphs.get(name, default)

    def space(self, name: str, default: int = 0) -> int:
        return self.spacing.get(name, default)


class ThemeManager:
    def __init__(self, themes: Mapping[str, Theme], default: str = "default") -> None:
        if default not in themes:
            raise ValueError(f"default theme not registered: {default}")
        self._themes = dict(themes)
        self._default = default

    def get(self, name: str | None = None) -> Theme:
        if not name:
            return self._themes[self._default]
        return self._themes.get(name, self._themes[self._default])

    def names(self) -> tuple[str, ...]:
        return tuple(sorted(self._themes))
