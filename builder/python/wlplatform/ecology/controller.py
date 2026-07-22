from datetime import datetime, timezone

from .transition import ALLOWED_TRANSITIONS
from .policy import STATE_REQUIREMENTS


class EcologyController:

    VERSION = "1.1.0"


    def __init__(self):
        self.state = "ACTIVE"


    def status(self):

        return {
            "component": "runtime-ecology",
            "version": self.VERSION,
            "state": self.state,
            "policy": STATE_REQUIREMENTS[self.state],
            "certified": True
        }


    def validate_transition(self, target):

        allowed = ALLOWED_TRANSITIONS.get(
            self.state,
            []
        )

        if target not in allowed:

            raise RuntimeError(
                f"Denied transition "
                f"{self.state}->{target}"
            )


    def transition(self, target):

        self.validate_transition(target)

        previous = self.state

        self.state = target


        return {
            "component": "runtime-ecology",
            "previous": previous,
            "state": self.state,
            "policy": STATE_REQUIREMENTS[self.state],
            "certified": True,
            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat()
        }
