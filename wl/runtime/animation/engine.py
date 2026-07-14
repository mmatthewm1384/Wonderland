from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol

from wl.runtime.animation.clock import FrameClock
from wl.runtime.animation.frame import AnimationFrame


class Animation(Protocol):
    name: str

    def render(self, frame: AnimationFrame, width: int) -> list[str]:
        ...


@dataclass
class AnimationEngine:
    animation: Animation
    clock: FrameClock

    def frame(self, index: int, *, width: int, progress: float = 0.0) -> list[str]:
        return self.animation.render(
            self.clock.frame(index, progress=progress),
            width,
        )
