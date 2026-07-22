"""
PRISMX Live Source Model
"""

from dataclasses import dataclass, field
from datetime import datetime


@dataclass
class PrismLiveSource:

    name: str
    protocol: str
    endpoint: str

    enabled: bool = True

    status: str = "offline"

    metadata: dict = field(
        default_factory=dict
    )

    created_at: str = field(
        default_factory=lambda:
        datetime.utcnow().isoformat()
    )


    def validate(self):

        supported = {
            "rtsp",
            "hls",
            "dash",
            "webrtc"
        }

        if self.protocol not in supported:
            raise ValueError(
                f"Unsupported live protocol: {self.protocol}"
            )

        if not self.endpoint:
            raise ValueError(
                "Live source endpoint required"
            )

        return True
