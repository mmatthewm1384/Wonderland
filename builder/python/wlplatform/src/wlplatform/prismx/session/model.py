"""
PRISMX Playback Session Model
"""

from dataclasses import dataclass, field
from datetime import datetime
import uuid

from .state import SessionState


@dataclass
class PrismSession:

    source: str

    id: str = field(
        default_factory=lambda:
        str(uuid.uuid4())
    )

    state: SessionState = (
        SessionState.CREATED
    )

    created_at: str = field(
        default_factory=lambda:
        datetime.utcnow().isoformat()
    )

    metadata: dict = field(
        default_factory=dict
    )


    def transition(self, state):

        self.state = state

        return self
