"""
PRISMX Playback Orchestrator

Connects:
Registry -> Resolver -> Session -> Player
"""

from .resolver import PrismResolver
from .player import VLCAdapter
from .session import PrismSessionManager


class PrismPlaybackOrchestrator:


    def __init__(
        self,
        registry=None,
        resolver=None,
        sessions=None,
        player=None
    ):

        self.registry = registry

        self.resolver = (
            resolver
            or PrismResolver()
        )

        self.sessions = (
            sessions
            or PrismSessionManager()
        )

        self.player = (
            player
            or VLCAdapter()
        )


    def open(
        self,
        stream_name
    ):

        if not self.registry:

            raise RuntimeError(
                "PRISMX registry unavailable"
            )


        stream = self.registry.get(
            stream_name
        )


        resolved = self.resolver.resolve(
            stream
        )


        if not resolved.authorized:

            raise PermissionError(
                "Source authorization failed"
            )


        session = self.sessions.create(
            resolved.source
        )


        self.player.open(
            resolved.source
        )


        return {
            "session": session,
            "source": resolved
        }


    def play(
        self,
        stream_name
    ):

        result = self.open(
            stream_name
        )

        session = result["session"]

        self.player.play()

        self.sessions.start(
            session.id
        )

        return {
            "session": session,
            "player":
                self.player.status()
        }
