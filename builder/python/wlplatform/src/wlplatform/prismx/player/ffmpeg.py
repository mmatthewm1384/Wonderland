"""
PRISMX FFmpeg Adapter
"""

from .adapter import PlayerAdapter


class FFmpegAdapter(PlayerAdapter):


    def __init__(self):

        self.source = None
        self.state = "idle"


    def open(self, source):

        self.source = source
        self.state = "ready"

        return True


    def play(self):

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
            "backend": "ffmpeg",
            "source": self.source,
            "state": self.state
        }
