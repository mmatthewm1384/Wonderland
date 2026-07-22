"""
Certification Trust Attestation Engine

Creates portable certification trust statements.
"""

import json
from datetime import datetime, timezone
from pathlib import Path


class CertificationAttestation:


    def __init__(
        self,
        subject="certification"
    ):

        self.subject = subject



    def create(
        self,
        policy,
        governance,
        validation,
        status="CERTIFIED"
    ):

        return {

            "attestation":
                "certification-trust",

            "version":
                "1.1",

            "generated":
                datetime.now(
                    timezone.utc
                ).isoformat(),

            "subject": {

                "engine":
                    self.subject
            },


            "trust": {

                "status":
                    status
            },


            "proof": {

                "policy":
                    policy,

                "governance":
                    governance,

                "validation":
                    validation
            }
        }



    def write(
        self,
        path,
        data
    ):

        Path(path).write_text(
            json.dumps(
                data,
                indent=2
            )
        )
