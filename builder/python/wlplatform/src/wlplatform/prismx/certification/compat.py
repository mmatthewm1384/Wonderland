"""
PRISMX Certification Compatibility API
"""

from .engine import PrismCertificationEngine


class PrismCertification:


    def __init__(self):

        self.engine = PrismCertificationEngine()


    def verify(self):

        record = self.engine.certify(
            "prismx",
            {
                "identity": True,
                "registry": True,
                "security": True,
                "transport": True,
                "player": True,
            }
        )

        return {
            "certified":
                record.status == "certified",
            "status":
                record.status,
            "checks":
                record.checks,
        }
