from dataclasses import dataclass


@dataclass
class RecoveryRequest:

    operation: str
    target: str
    risk: str
    emergency: bool = False


@dataclass
class PolicyDecision:

    decision: str
    reason: str


