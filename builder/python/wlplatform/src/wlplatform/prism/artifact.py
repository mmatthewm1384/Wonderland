from dataclasses import dataclass, field
from datetime import datetime, timezone
import uuid


@dataclass
class PrismArtifact:
    """
    Base PRISM artifact.

    Security and privacy are default properties.
    """

    artifact_id: str = field(
        default_factory=lambda: str(uuid.uuid4())
    )

    created: str = field(
        default_factory=lambda:
        datetime.now(timezone.utc).isoformat()
    )

    artifact_type: str = "prism"

    encrypted: bool = True

    metadata_protected: bool = True

    privacy_mode: str = "default"

    def describe(self):
        return {
            "id": self.artifact_id,
            "type": self.artifact_type,
            "encrypted": self.encrypted,
            "metadata_protected": self.metadata_protected,
            "privacy_mode": self.privacy_mode,
        }
