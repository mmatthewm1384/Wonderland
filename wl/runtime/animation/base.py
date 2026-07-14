from __future__ import annotations

from abc import ABC, abstractmethod

from wl.runtime.animation.frame import AnimationFrame


class BaseAnimation(ABC):
    name: str

    @abstractmethod
    def render(self, frame: AnimationFrame, width: int) -> list[str]:
        raise NotImplementedError
