from __future__ import annotations

import time
from typing import Any

from wl.runtime.context import RuntimeContext
from wl.runtime.renderer import Renderer
from wl.runtime.screen import Screen


class RuntimeKernel:
    """Runtime lifecycle owner.

    Scenes do not own loops, sleep, terminal state, or flushing.
    """

    def __init__(
        self,
        context: RuntimeContext,
        *,
        screen: Any | None = None,
        renderer: Renderer | None = None,
        frame_interval: float = 0.05,
        alternate_screen: bool = True,
    ) -> None:
        self.context = context
        self.screen = screen or Screen()
        self.renderer = renderer or Renderer(self.screen)
        self.frame_interval = max(0.0, frame_interval)
        self.alternate_screen = alternate_screen

    def run(self, scene: Any) -> int:
        if hasattr(self.screen, "enter"):
            self.screen.enter(alternate_screen=self.alternate_screen)

        try:
            scene.mount(self.context)
            running = True
            while running:
                running = bool(scene.update(self.context))
                frame = scene.render(self.context)
                self.renderer.render(frame)
                if running and self.frame_interval:
                    time.sleep(self.frame_interval)
            return 0
        finally:
            try:
                scene.unmount(self.context)
            finally:
                if hasattr(self.screen, "exit"):
                    self.screen.exit(alternate_screen=self.alternate_screen)
