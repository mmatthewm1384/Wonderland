from __future__ import annotations

from dataclasses import dataclass

from wl.runtime.presentation.components import status_list


@dataclass(frozen=True)
class StatusListWidget:
    items: list[tuple[str, str]]

    def render(self, width: int) -> list[str]:
        return status_list(self.items)
