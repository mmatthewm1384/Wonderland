from __future__ import annotations


class NullPluginManager:
    def __init__(self, reason: str = "plugins unavailable"):
        self.reason = reason

    def discover(self) -> None:
        return None

    def before_cycle(self) -> None:
        return None

    def after_cycle(self, state: dict) -> None:
        return None

    def on_event(self, event: dict) -> None:
        return None

    def status(self) -> dict:
        return {
            "enabled": False,
            "count": 0,
            "plugins": [],
            "errors": [self.reason],
        }
