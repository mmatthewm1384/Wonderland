from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class AnimationFrame:
    index: int
    elapsed: float
    delta: float
    progress: float

    @property
    def elapsed_ms(self) -> int:
        return int(self.elapsed * 1000)
