from __future__ import annotations

import time
from dataclasses import dataclass, field

from wl.runtime.animation.frame import AnimationFrame


@dataclass
class FrameClock:
    target_fps: float = 60.0
    started: float = field(default_factory=time.perf_counter)
    previous: float = field(default_factory=time.perf_counter)

    @property
    def frame_delay(self) -> float:
        if self.target_fps <= 0:
            return 0.0
        return 1.0 / self.target_fps

    def frame(self, index: int, *, progress: float = 0.0) -> AnimationFrame:
        now = time.perf_counter()
        delta = max(0.0, now - self.previous)
        self.previous = now

        return AnimationFrame(
            index=index,
            elapsed=max(0.0, now - self.started),
            delta=delta,
            progress=max(0.0, min(1.0, progress)),
        )

    def sleep(self) -> None:
        delay = self.frame_delay
        if delay > 0:
            time.sleep(delay)
