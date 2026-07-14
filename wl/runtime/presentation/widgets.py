from __future__ import annotations

from wl.runtime.widgets.base import Widget


def render_widgets(widgets: list[Widget], width: int, gap: int = 1) -> list[str]:
    lines: list[str] = []

    for index, widget in enumerate(widgets):
        if index:
            lines.extend([""] * gap)
        lines.extend(widget.render(width))

    return lines
