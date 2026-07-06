from __future__ import annotations

from typing import Protocol

from wlcli.core.events.bus import RuntimeEvent
from wlcli.core.runtime.context import RuntimeContext


class EventSubscriber(Protocol):
    name: str

    def handle(self, context: RuntimeContext, event: RuntimeEvent) -> None:
        ...
