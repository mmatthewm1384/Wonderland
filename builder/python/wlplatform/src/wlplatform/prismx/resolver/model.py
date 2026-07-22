"""
PRISMX Resolver Result
"""

from dataclasses import dataclass, field


@dataclass
class PrismResolvedSource:

    name: str
    source: str
    protocol: str

    authorized: bool = False

    capabilities: dict = field(
        default_factory=dict
    )

    metadata: dict = field(
        default_factory=dict
    )
