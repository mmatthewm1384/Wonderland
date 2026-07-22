"""
PRISMX Runtime Events
"""

from dataclasses import dataclass, field
from datetime import datetime
import uuid


@dataclass
class PrismEvent:

    event: str
    component: str

    id: str = field(
        default_factory=lambda:
        str(uuid.uuid4())
    )

    timestamp: str = field(
        default_factory=lambda:
        datetime.utcnow().isoformat()
    )

    metadata: dict = field(
        default_factory=dict
    )
