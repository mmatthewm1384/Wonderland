"""
PRISMX Registry Storage

Loads declarative stream registry data.
"""

import json
from pathlib import Path

from .stream import PrismStream


class PrismRegistryStorage:

    def __init__(self, path):

        self.path = Path(path)


    def load(self):

        if not self.path.exists():
            raise FileNotFoundError(
                f"PRISMX registry missing: {self.path}"
            )

        with self.path.open("r") as file:
            data = json.load(file)

        return self._parse(data)


    def _parse(self, data):

        streams = []

        for item in data.get("streams", []):

            source = item.get("source", {})

            streams.append(
                PrismStream(
                    name=item["id"],
                    source=source.get("uri"),
                    protocol=source.get("protocol"),
                    metadata=item.get(
                        "metadata",
                        {}
                    )
                )
            )

        return streams
