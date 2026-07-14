from __future__ import annotations

from dataclasses import dataclass

from wl.runtime.presentation.layout import center


@dataclass(frozen=True)
class PanelWidget:
    lines: list[str]
    padding: int = 1

    def render(self, width: int) -> list[str]:
        content_width = min(max((len(line) for line in self.lines), default=0), max(width - 4, 20))
        border = "─" * (content_width + self.padding * 2)

        rendered = [center(f"╭{border}╮", width)]
        for line in self.lines:
            rendered.append(center(f"│{' ' * self.padding}{line.ljust(content_width)}{' ' * self.padding}│", width))
        rendered.append(center(f"╰{border}╯", width))
        return rendered
