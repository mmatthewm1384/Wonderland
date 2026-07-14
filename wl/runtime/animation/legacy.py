from __future__ import annotations

from dataclasses import dataclass

from wl.runtime.animation.base import BaseAnimation
from wl.runtime.animation.frame import AnimationFrame
from wl.runtime.animation.presets import spinner_lines
from wl.runtime.presentation.layout import center


@dataclass(frozen=True)
class LegacyPresetAnimation(BaseAnimation):
    name: str
    theme: str = "neon"

    def render(self, frame: AnimationFrame, width: int) -> list[str]:
        lines = spinner_lines(
            frame.index,
            preset=self.name,
            theme=self.theme,
        )

        if not lines:
            return [
                center(f"[animation unavailable: {self.name}]", width),
            ]

        return [
            center(line, width)
            for line in lines
            if line.strip()
        ] or [
            center(f"[animation blank: {self.name}]", width),
        ]
