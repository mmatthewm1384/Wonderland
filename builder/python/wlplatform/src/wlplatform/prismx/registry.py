"""
PRISMX Registry Loader
"""

import json
from pathlib import Path

from .live import PrismLiveSource


class PrismRegistry:

    def get(self, name):

        if name in self.streams:
            return self.streams[name]


        normalized = name.lower().replace(
            "-",
            " "
        )


        for key, stream in self.streams.items():

            if key.lower() == name.lower():
   
                return stream

            if key.lower().replace(
                "-",
                " "
            ) == normalized:

                return stream


        raise KeyError(
            f"Unknown PRISMX stream: {name}"
        )

    def __init__(self, path=None):

        self.path = (
            Path(path)
            if path
            else None
        )

        self.streams = {}


    def register(self, stream):

        stream.validate()

        self.streams[
            stream.name
        ] = stream

        return stream


    def load(self, path=None):

        if path:

            self.path = Path(path)


        if not self.path:

            raise ValueError(
                "PRISMX registry path not configured"
            )


        if not self.path.exists():

            raise FileNotFoundError(
                f"Missing registry: {self.path}"
            )


        with self.path.open() as file:

            data = json.load(file)


        for item in data.get(
            "streams",
            []
        ):

            stream = PrismLiveSource(
                name=item.get(
                    "name",
                    item["id"]
                ),
                protocol=item["protocol"],
                endpoint=item["source"],
                enabled=item.get(
                    "enabled",
                    True
                ),
                metadata=item.get(
                    "metadata",
                    {}
                )
            )

            self.register(stream)


        return self


    def get(self, name):

        return self.streams[name]


    def list(self):

        return list(
            self.streams.values()
        )
