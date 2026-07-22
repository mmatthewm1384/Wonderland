from __future__ import annotations


class EventOrchestrator:

    TERMINAL_EVENTS = {
        "ENGINE_INSTALL_COMPLETED",
        "ENGINE_INSTALL_FAILED",
        "ENGINE_ROLLBACK_COMPLETED",
    }


    def __init__(self, events):

        self.events = events


    def latest_state(self, engine):

        matching = [
            e for e in self.events
            if e.get("engine") == engine
        ]

        if not matching:
            return None

        return matching[-1]["event_type"]


    def can_complete(self, engine):

        state = self.latest_state(engine)

        return state not in self.TERMINAL_EVENTS


    def detect_duplicate(self, event):

        for existing in self.events:
            if (
                existing["engine"] == event["engine"]
                and existing["event_type"]
                == event["event_type"]
                and existing["payload"]
                == event["payload"]
            ):
                return True

        return False
