from __future__ import annotations

from wlcli.core.events.subscribers.history import HistorySubscriber
from wlcli.core.events.subscribers.metrics import MetricsSubscriber


def default_subscribers():
    return [
        HistorySubscriber(),
        MetricsSubscriber(),
    ]


__all__ = ["HistorySubscriber", "MetricsSubscriber", "default_subscribers"]
