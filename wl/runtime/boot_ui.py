from __future__ import annotations

from dataclasses import dataclass

from wl.runtime.context import RuntimeContext
from wl.runtime.frame import Align, Box, Frame, Rule, Style, Text


@dataclass(frozen=True)
class BootUIState:
    tick: int
    max_ticks: int
    title: str = "Wonderland Runtime"
    status: str = "RuntimeKernel online"

    @property
    def progress(self) -> float:
        if self.max_ticks <= 0:
            return 1.0
        return min(1.0, max(0.0, self.tick / self.max_ticks))


class BootUI:
    """Presentation-only boot UI.

    This class returns Frame objects only. It must not manage terminal state,
    sleep, loops, flushing, or ANSI sequences.
    """

    def render(self, state: BootUIState, context: RuntimeContext) -> Frame:
        width = 72
        progress_width = 44
        filled = int(progress_width * state.progress)
        bar = "█" * filled + "░" * (progress_width - filled)

        return Frame.from_commands(
            Box(row=2, col=4, width=width, height=11, title=" Wonderland "),
            Text(state.title, row=4, align=Align.CENTER, style=Style(role="header", bold=True)),
            Rule(row=6, col=8, width=width - 8),
            Text(f"Theme: {context.theme}", row=8, col=8, style=Style(role="muted")),
            Text(state.status, row=9, col=8, style=Style(role="success")),
            Text(f"[{bar}] {int(state.progress * 100):3d}%", row=11, col=8, style=Style(role="progress")),
        )
