from __future__ import annotations

from dataclasses import dataclass

from wl.runtime.presentation.components import header


@dataclass(frozen=True)
class HeaderWidget:
    title: str
    subtitle: str | None = None

    def render(self, width: int) -> list[str]:
        return header(title=self.title, subtitle=self.subtitle or "")
