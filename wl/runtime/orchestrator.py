from __future__ import annotations

from typing import Any

from wl.runtime.context import RuntimeContext
from wl.runtime.launcher import run_scene


class RuntimeOrchestrator:
    # Legacy orchestration facade.
    #
    # Runtime Phase 2 uses RuntimeKernel directly. This facade exists for older
    # import paths and delegates to the canonical launcher.

    def __init__(self, context: RuntimeContext | None = None) -> None:
        self.context = context or RuntimeContext()

    def run(self, scene: Any, *, screen: Any | None = None, alternate_screen: bool = True) -> int:
        return run_scene(
            scene,
            context=self.context,
            screen=screen,
            alternate_screen=alternate_screen,
        )


__all__ = ["RuntimeOrchestrator"]
