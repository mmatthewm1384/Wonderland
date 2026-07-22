"""
PRISMX Certification Record
"""

from dataclasses import dataclass, field
from datetime import datetime
import uuid


@dataclass
class PrismCertificationRecord:

    component: str

    id: str = field(
        default_factory=lambda:
        str(uuid.uuid4())
    )

    status: str = "pending"

    checks: dict = field(
        default_factory=dict
    )

    created_at: str = field(
        default_factory=lambda:
        datetime.utcnow().isoformat()
    )


    def certify(self):

        self.status = (
            "certified"
            if all(self.checks.values())
            else "failed"
        )

        return self
