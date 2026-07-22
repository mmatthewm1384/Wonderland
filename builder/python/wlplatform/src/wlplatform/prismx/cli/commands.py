"""
PRISMX CLI Commands
"""

from ..orchestrator import PrismPlaybackOrchestrator
from ..observer import PrismObserver
from ..certification import PrismCertification
from ..live import PrismLiveManager
from ..player import VLCAdapter

from pathlib import Path
from ..registry import PrismRegistry


streams = PrismRegistry(
    Path(
        "vault/05-Registry/prismx/streams.json"
    )
).load()

observer = PrismObserver()

player = VLCAdapter()

def play_stream(name):

    controller = PrismPlaybackOrchestrator(
        registry=streams
    )

    result = controller.play(
        name
    )

    return {
        "session":
            result["session"].__dict__,
        "player":
            result["player"]
    }

def status():

    return {
        "component": "prismx",
        "observer": observer.status()
    }


def list_streams():

    return [
        stream.__dict__
        for stream in streams.list()
    ]


def play(source):

    player.open(source)
    player.play()

    observer.emit(
        "playback.started",
        "prismx",
        {
            "source": source
        }
    )

    return player.status()


def certify():

    return PrismCertification().verify()


def recover():

    observer.emit(
        "recovery.requested",
        "prismx"
    )

    return {
        "recovered": True
    }
