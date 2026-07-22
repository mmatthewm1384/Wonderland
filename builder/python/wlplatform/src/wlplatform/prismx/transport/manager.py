"""
PRISMX Transport Manager
"""

from .model import PrismTransport


SUPPORTED = {
    "rtsp",
    "hls",
    "dash",
    "webrtc"
}


class PrismTransportManager:


    def create(
        self,
        protocol,
        endpoint
    ):

        if protocol not in SUPPORTED:

            raise ValueError(
                f"Unsupported transport: {protocol}"
            )

        return PrismTransport(
            protocol=protocol,
            endpoint=endpoint
        )


    def connect(
        self,
        transport
    ):

        return transport.connect()


    def disconnect(
        self,
        transport
    ):

        return transport.disconnect()
