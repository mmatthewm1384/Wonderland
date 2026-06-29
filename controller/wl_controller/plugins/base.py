from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol


@dataclass
class PluginContext:
    root: str
    controller_version: str


class ControllerPlugin(Protocol):
    name: str

    def initialize(self, context: PluginContext) -> None: ...
    def before_cycle(self) -> None: ...
    def after_cycle(self, state: dict) -> None: ...
    def on_event(self, event: dict) -> None: ...
