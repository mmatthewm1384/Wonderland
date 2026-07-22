"""
Certification Governance Engine

Validates governance state around
certification policy lifecycle.
"""

import json
from pathlib import Path


class CertificationGovernance:


    def __init__(self, data):

        self.data = data



    @classmethod
    def load(cls, path):

        return cls(
            json.loads(
                Path(path).read_text()
            )
        )



    def approved(self):

        return (
            self.data
            .get("approval", {})
            .get("status")
            ==
            "APPROVED"
        )



    def owner(self):

        return (
            self.data
            .get("ownership", {})
            .get("authority")
        )



    def validate(self):

        return {

            "approved":
                self.approved(),

            "owner":
                self.owner(),

            "version":
                self.data.get(
                    "version"
                )
        }
