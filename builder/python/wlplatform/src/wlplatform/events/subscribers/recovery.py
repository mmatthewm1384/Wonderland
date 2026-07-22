from ..subscriber import EventSubscriber


class RecoverySubscriber(
    EventSubscriber
):

    name = "recovery"


    def handles(
        self,
        event
    ):

        return event["event_type"] in {
            "ENGINE_INSTALL_FAILED",
            "ENGINE_ROLLBACK_STARTED",
        }


    def process(
        self,
        event
    ):

        return {
            "subscriber": self.name,
            "action": "recovery_prepare",
            "engine": event["engine"],
        }
