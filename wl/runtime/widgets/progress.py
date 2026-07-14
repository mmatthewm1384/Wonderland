from __future__ import annotations

from dataclasses import dataclass

from wl.runtime.presentation.progress import progress_bar


@dataclass(frozen=True)
class ProgressWidget:
    value: float
    width: int = 44

    def render(self, terminal_width: int) -> list[str]:
        return [progress_bar(self.value, self.width)]
