from __future__ import annotations

from wl.runtime.boot_ui import BootUI, BootUIState
from wl.runtime.context import RuntimeContext
from wl.runtime.frame import Frame


class BootScene:
    def __init__(self, *, max_ticks: int = 60, ui: BootUI | None = None) -> None:
        self.max_ticks = max(1, int(max_ticks))
        self.ticks = 0
        self.ui = ui or BootUI()

    def mount(self, context: RuntimeContext) -> None:
        self.ticks = 0

    def update(self, context: RuntimeContext) -> bool:
        self.ticks += 1
        return self.ticks < self.max_ticks

    def render(self, context: RuntimeContext) -> Frame:
        return self.ui.render(
            BootUIState(tick=self.ticks, max_ticks=self.max_ticks),
            context,
        )

    def unmount(self, context: RuntimeContext) -> None:
        return None
