"""
Wonderland Event Bus Policy Enforcement Subscriber.

Validates:
- event type
- required fields
- forbidden transitions
"""

from __future__ import annotations


class PolicyViolation(Exception):
    pass


class PolicySubscriber:

    name = "policy"


    def __init__(self, policy):

        self.policy = policy


    def handles(
        self,
        event: dict
    ) -> bool:

        return event.get(
            "event_type",
            ""
        ).startswith(
            "ENGINE_"
        )


    def process(
        self,
        event: dict
    ) -> dict:

        decision = self.evaluate(
            event
        )

        return {
            "subscriber": self.name,
            "event_id": event.get(
                "event_id"
            ),
            "decision": decision,
            "engine": event.get(
                "engine"
            ),
        }


    def evaluate(
        self,
        event: dict
    ):

        event_type = event.get(
            "event_type"
        )

        required = self.policy.get(
            "required_fields",
            []
        )

        for field in required:

            if not event.get(field):
                return "BLOCKED"


        if event_type in self.policy.get(
            "blocked_events",
            []
        ):
            return "BLOCKED"


        if event_type not in self.policy.get(
            "allowed_events",
            []
        ):
            return "BLOCKED"


        return "ALLOWED"
