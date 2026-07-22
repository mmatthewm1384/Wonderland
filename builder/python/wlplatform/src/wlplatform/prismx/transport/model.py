"""
PRISMX Transport Model
"""

from dataclasses import dataclass


@dataclass
class PrismTransport:

    protocol: str
    endpoint: str

    connected: bool = False


    def connect(self):

        self.connected = True

        return self


    def disconnect(self):

        self.connected = False

        return self
