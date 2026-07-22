"""
PRISMX Recovery Checkpoint
"""

from dataclasses import dataclass, field
from datetime import datetime


@dataclass
class PrismCheckpoint:

    session_id: str
    source: str
    state: str

    created_at: str = field(
        default_factory=lambda:
        datetime.utcnow().isoformat()
    )
