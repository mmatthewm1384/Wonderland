"""
PRISMX Certification Engine
"""

from .model import PrismCertificationRecord


class PrismCertificationEngine:


    def certify(
        self,
        component,
        checks
    ):

        record = PrismCertificationRecord(
            component=component,
            checks=checks
        )

        return record.certify()
