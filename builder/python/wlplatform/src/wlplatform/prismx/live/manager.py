"""
PRISMX Live Source Manager
"""

from .model import PrismLiveSource


class PrismLiveManager:


    def __init__(self):

        self.sources = {}


    def register(
        self,
        source: PrismLiveSource
    ):

        source.validate()

        self.sources[
            source.name
        ] = source

        return source


    def start(
        self,
        name
    ):

        source = self.get(name)

        source.status = "online"

        return source


    def stop(
        self,
        name
    ):

        source = self.get(name)

        source.status = "offline"

        return source


    def get(
        self,
        name
    ):

        if name not in self.sources:

            raise KeyError(
                f"Unknown live source: {name}"
            )

        return self.sources[name]


    def list(self):

        return list(
            self.sources.values()
        )
