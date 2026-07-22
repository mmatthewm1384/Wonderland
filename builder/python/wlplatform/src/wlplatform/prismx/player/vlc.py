"""
PRISMX VLC Adapter

Future libVLC integration boundary.
"""

from .adapter import PlayerAdapter


class VLCAdapter(PlayerAdapter):


    def __init__(self):

        self.source = None
        self.state = "idle"


    def open(self, source):

        self.source = source
        self.state = "ready"

        return True


    def play(self):

        if not self.source:

            raise RuntimeError(
                "No source loaded"
            )

        self.state = "playing"

        return True


    def pause(self):

        self.state = "paused"

        return True


    def stop(self):

        self.state = "stopped"

        return True


    def status(self):

        return {
            "backend": "vlc",
            "source": self.source,
            "state": self.state
        }
