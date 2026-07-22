"""
PRISMX Media Identity
"""

from dataclasses import dataclass
from datetime import datetime
import hashlib
import json


@dataclass
class PrismIdentity:

    name: str
    owner: str
    origin: str

    fingerprint: str = None


    def generate(self):

        payload = json.dumps(
            {
                "name": self.name,
                "owner": self.owner,
                "origin": self.origin
            },
            sort_keys=True
        )

        self.fingerprint = hashlib.sha256(
            payload.encode()
        ).hexdigest()

        return self

    def create_identity(
        name,
        owner,
        origin
    ):
    
        return (
            PrismIdentity(
                name=name,
                owner=owner,
                origin=origin
            )
            .generate()
        )
