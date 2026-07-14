from __future__ import annotations

from pathlib import Path
from typing import Any

from wl.runtime.context import RuntimeContext
from wl.runtime.kernel import RuntimeKernel
from wl.runtime.scenes.boot import BootScene


def run_scene(
    scene: Any,
    *,
    context: RuntimeContext | None = None,
    screen: Any | None = None,
    alternate_screen: bool = True,
    frame_interval: float = 0.05,
) -> int:
    kernel = RuntimeKernel(
        context or RuntimeContext(),
        screen=screen,
        alternate_screen=alternate_screen,
        frame_interval=frame_interval,
    )
    return int(kernel.run(scene))


def launch_rootless(
    *,
    ticks: int = 60,
    interactive: bool = True,
    state_dir: str | None = None,
    theme: str = "default",
) -> int:
    context = RuntimeContext(
        interactive=interactive,
        state_dir=Path(state_dir) if state_dir is not None else None,
        theme=theme,
    )
    return run_scene(BootScene(max_ticks=ticks), context=context)
