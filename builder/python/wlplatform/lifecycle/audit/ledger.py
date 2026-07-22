from .models import AuditEvent


class LifecycleAuditLedger:


    def __init__(self):

        self.events = []



    def append(
        self,
        event
    ):

        if self.events:

            event.previous_hash = (
                self.events[-1]["hash"]
            )


        record = event.export()

        self.events.append(
            record
        )

        return record



    def latest(self):

        return self.events[-1]
