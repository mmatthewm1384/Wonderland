from ..subscriber import EventSubscriber


class LedgerSubscriber(
    EventSubscriber
):

    name = "ledger"


    def handles(
        self,
        event
    ):

        return event["event_type"].startswith(
            "ENGINE_"
        )


    def process(
        self,
        event
    ):

        return {
            "subscriber": self.name,
            "action": "ledger_append",
            "event_id": event["event_id"],
        }
