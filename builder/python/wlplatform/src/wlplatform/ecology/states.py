from enum import Enum


class EcologyState(str, Enum):
    ACTIVE = "ACTIVE"
    FLOW = "FLOW"
    RESTING = "RESTING"
    DREAM = "DREAM"
    SANCTUARY = "SANCTUARY"
