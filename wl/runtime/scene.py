from __future__ import annotations

from typing import Protocol

from wl.runtime.context import RuntimeContext
from wl.runtime.frame import Frame


class Scene(Protocol):
    def mount(self, context: RuntimeContext) -> None:
        ...

    def update(self, context: RuntimeContext) -> bool:
        ...

    def render(self, context: RuntimeContext) -> Frame:
        ...

    def unmount(self, context: RuntimeContext) -> None:
        ...
