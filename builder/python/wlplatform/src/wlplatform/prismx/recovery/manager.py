"""
PRISMX Recovery Manager
"""


from .checkpoint import PrismCheckpoint


class PrismRecoveryManager:


    def __init__(self):

        self.checkpoints = {}


    def checkpoint(
        self,
        session
    ):

        record = PrismCheckpoint(
            session_id=session.id,
            source=session.source,
            state=session.state.value
        )

        self.checkpoints[
            session.id
        ] = record

        return record


    def restore(
        self,
        session_id
    ):

        if session_id not in self.checkpoints:

            raise KeyError(
                "No recovery checkpoint"
            )

        return self.checkpoints[
            session_id
        ]
