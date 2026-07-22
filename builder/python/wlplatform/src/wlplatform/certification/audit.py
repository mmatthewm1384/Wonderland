"""
Certification Audit Ledger

Maintains historical certification events.
"""

import json
from datetime import datetime, timezone
from pathlib import Path


class CertificationAuditLedger:


    def __init__(self, path):

        self.path = Path(path)



    def append(
        self,
        event,
        engine,
        policy,
        governance,
        trust
    ):

        record = {

            "event":
                event,

            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat(),

            "engine":
                engine,

            "policy":
                policy,

            "governance":
                governance,

            "trust":
                trust
        }


        with self.path.open(
            "a"
        ) as file:

            file.write(
                json.dumps(record)
                +
                "\n"
            )


        return record



    def entries(self):

        if not self.path.exists():

            return []


        return [
            json.loads(line)
            for line in self.path.read_text()
            .splitlines()
            if line
        ]



    def verify(self):

        return all(
            entry.get("trust")
            in [
                "CERTIFIED",
                "FAILED"
            ]

            for entry
            in self.entries()
        )
