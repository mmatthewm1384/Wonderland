"""
PRISMX Playback Controller

Coordinates sessions and media backends.
"""

from .session import PrismSessionManager
from .player import VLCAdapter


class PrismPlaybackController:


    def __init__(
        self,
        session_manager=None,
        player=None
    ):

        self.sessions = (
            session_manager
            or PrismSessionManager()
        )

        self.player = (
            player
            or VLCAdapter()
        )


    def open(self, source):

        session = self.sessions.create(
            source
        )

        self.player.open(
            source
        )

        return session


    def play(self, session_id):

        self.player.play()

        session = self.sessions.start(
            session_id
        )

        return session


    def pause(self, session_id):

        self.player.pause()

        session = self.sessions.pause(
            session_id
        )

        return session


    def stop(self, session_id):

        self.player.stop()

        session = self.sessions.stop(
            session_id
        )

        return session


    def status(self):

        return {
            "player":
                self.player.status(),

            "sessions":
                [
                    {
                        "id": s.id,
                        "state": s.state.value,
                        "source": s.source,
                    }
                    for s in self.sessions.list()
                ]
        }
