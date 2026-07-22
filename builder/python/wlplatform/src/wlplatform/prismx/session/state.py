from enum import Enum


class SessionState(Enum):

    CREATED = "created"
    READY = "ready"
    PLAYING = "playing"
    PAUSED = "paused"
    STOPPED = "stopped"
    FAILED = "failed"
