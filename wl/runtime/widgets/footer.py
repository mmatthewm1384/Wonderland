from __future__ import annotations

from dataclasses import dataclass

from wl.runtime.presentation.components import footer


@dataclass(frozen=True)
class FooterWidget:
    text: str

    def render(self, width: int) -> list[str]:
        return footer(self.text)
