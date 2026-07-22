"""
Wonderland Event Subscriber Contract.
"""

from __future__ import annotations

from abc import ABC, abstractmethod


class EventSubscriber(ABC):

    name = "unknown"

    @abstractmethod
    def handles(self, event: dict) -> bool:
        pass


    @abstractmethod
    def process(self, event: dict) -> dict | None:
        pass
