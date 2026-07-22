"""
PRISMX Observer
"""

from .events import PrismEvent
from .metrics import PrismMetrics


class PrismObserver:


    def __init__(self):

        self.events = []
        self.metrics = PrismMetrics()


    def emit(
        self,
        event,
        component,
        metadata=None
    ):

        record = PrismEvent(
            event=event,
            component=component,
            metadata=metadata or {}
        )

        self.events.append(record)

        return record


    def status(self):

        return {
            "events":
                len(self.events),
            "metrics":
                self.metrics.snapshot()
        }
