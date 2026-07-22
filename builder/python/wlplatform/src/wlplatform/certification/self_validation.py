"""
Certification Self-Validation Engine

Validates certification subsystem integrity.
"""

import json
from pathlib import Path
from datetime import datetime, timezone


class CertificationSelfValidator:


    def __init__(self, root="."):

        self.root = Path(root)



    def check_exists(self, path):

        return (
            self.root / path
        ).exists()



    def validate(self):

        checks = []


        required = {

            "policy":
                "vault/08-Operations/"
                "policies/certification/"
                "certification-policy-v1.1.json",


            "governance":
                "vault/08-Operations/"
                "governance/certification/"
                "certification-governance-v1.1.json",


            "automation":
                "vault/08-Operations/"
                "certifications/automation/"
                "certification-automation.json"
        }


        for name, path in required.items():

            checks.append(
                {
                    "component":
                        name,

                    "status":
                        "PASS"
                        if self.check_exists(path)
                        else "FAIL"
                }
            )


        status = (
            "PASS"
            if all(
                c["status"] == "PASS"
                for c in checks
            )
            else "FAIL"
        )


        return {

            "engine":
                "certification",

            "validation":
                "self",

            "generated":
                datetime.now(
                    timezone.utc
                ).isoformat(),

            "status":
                status,

            "checks":
                checks
        }



    def write_report(self, path):

        report = self.validate()

        Path(path).write_text(
            json.dumps(
                report,
                indent=2
            )
        )

        return report
