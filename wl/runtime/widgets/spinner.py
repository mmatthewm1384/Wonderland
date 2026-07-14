from __future__ import annotations

from dataclasses import dataclass

from wl.runtime.presentation.layout import center


@dataclass(frozen=True)
class SpinnerWidget:
    lines: list[str]

    def render(self, width: int) -> list[str]:
        return [center(line, width) for line in self.lines]
