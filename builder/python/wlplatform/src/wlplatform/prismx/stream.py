from dataclasses import dataclass, field


SUPPORTED_PROTOCOLS = {
    "file",
    "rtsp",
    "hls",
    "dash",
    "webrtc",
}


@dataclass
class PrismStream:

    name: str
    source: str
    protocol: str
    enabled: bool = True
    metadata: dict = field(default_factory=dict)


    def validate(self):

        if not self.name:
            raise ValueError(
                "stream name required"
            )

        if not self.source:
            raise ValueError(
                "stream source required"
            )

        if self.protocol not in SUPPORTED_PROTOCOLS:
            raise ValueError(
                f"unsupported protocol: {self.protocol}"
            )

        return True
