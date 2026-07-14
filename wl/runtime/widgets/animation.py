from __future__ import annotations

from collections.abc import Iterable


class AnimationWidget:
    def __init__(self, animation, *, width: int, height: int | None = None):
        self.animation = animation
        self.width = max(20, width)
        self.height = height

    def render(self, *, frame: int, progress: float) -> list[str]:
        lines = self.animation.frame(
            frame,
            width=self.width,
            progress=progress,
        )

        if isinstance(lines, str):
            rendered = lines.splitlines()
        elif hasattr(lines, "text"):
            rendered = str(lines.text).splitlines()
        elif isinstance(lines, Iterable):
            rendered = [str(line) for line in lines]
        else:
            rendered = str(lines).splitlines()

        if self.height is not None:
            rendered = self._fit_height(rendered, self.height)

        return rendered

    def _fit_height(self, lines: list[str], height: int) -> list[str]:
        if len(lines) > height:
            start = max(0, (len(lines) - height) // 2)
            return lines[start : start + height]

        pad_total = height - len(lines)
        top = pad_total // 2
        bottom = pad_total - top
        return [""] * top + lines + [""] * bottom
