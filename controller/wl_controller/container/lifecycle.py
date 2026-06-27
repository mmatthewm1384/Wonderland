from __future__ import annotations

from dataclasses import dataclass, field
from typing import Callable


@dataclass
class LifecycleManager:
    startup_hooks: list[Callable[[], None]] = field(default_factory=list)
    shutdown_hooks: list[Callable[[], None]] = field(default_factory=list)

    def on_startup(self, fn: Callable[[], None]) -> None:
        self.startup_hooks.append(fn)

    def on_shutdown(self, fn: Callable[[], None]) -> None:
        self.shutdown_hooks.append(fn)

    def start(self) -> None:
        for hook in self.startup_hooks:
            hook()

    def stop(self) -> None:
        for hook in reversed(self.shutdown_hooks):
            hook()
