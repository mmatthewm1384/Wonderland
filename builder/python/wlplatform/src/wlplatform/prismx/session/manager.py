"""
PRISMX Session Lifecycle Manager
"""

from .model import PrismSession
from .state import SessionState


class PrismSessionManager:


    def __init__(self):

        self.sessions = {}


    def create(self, source):

        session = PrismSession(
            source=source
        )

        session.transition(
            SessionState.READY
        )

        self.sessions[
            session.id
        ] = session

        return session


    def start(self, session_id):

        session = self.get(
            session_id
        )

        session.transition(
            SessionState.PLAYING
        )

        return session


    def pause(self, session_id):

        session = self.get(
            session_id
        )

        session.transition(
            SessionState.PAUSED
        )

        return session


    def stop(self, session_id):

        session = self.get(
            session_id
        )

        session.transition(
            SessionState.STOPPED
        )

        return session


    def get(self, session_id):

        if session_id not in self.sessions:

            raise KeyError(
                f"Unknown PRISMX session: {session_id}"
            )

        return self.sessions[session_id]


    def list(self):

        return list(
            self.sessions.values()
        )
