from .models import LifecycleEvent


class LifecycleEventService:


    def __init__(self, ledger):

        self.ledger = ledger


    def transition(
        self,
        source,
        target,
        component,
        result="PASS",
        evidence=None
    ):

        event = LifecycleEvent(
            event="STATE_TRANSITION",
            source_state=source,
            target_state=target,
            component=component,
            result=result,
            evidence=evidence or {}
        )

        self.ledger.append(event)

        return event
