from dataclasses import dataclass


@dataclass
class PrismCapabilities:

    vlc: bool = True
    ffmpeg: bool = True
    hardware_decode: bool = False
    network_streams: bool = True



class CapabilityEngine:

    def detect(self):

        return PrismCapabilities()
