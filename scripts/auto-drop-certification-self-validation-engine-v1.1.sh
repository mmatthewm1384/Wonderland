#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$WL_ROOT"

echo "=============================================="
echo "Certification Self-Validation Engine v1.1"
echo "=============================================="


REPORT_DIR="vault/08-Operations/certifications/self-validation"

mkdir -p "$REPORT_DIR"


MODULE="builder/python/wlplatform/wlplatform/certification/self_validation.py"


cat > "$MODULE" <<'PYTHON'
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
PYTHON


REPORT="$REPORT_DIR/certification-self-validation.json"


python3 <<PYTHON
from pathlib import Path
from wlplatform.certification.self_validation import (
    CertificationSelfValidator
)

validator = CertificationSelfValidator(
    "."
)

validator.write_report(
    "$REPORT"
)

print("Self-validation report generated")
PYTHON


TEST="builder/python/wlplatform/tests/test_certification_self_validation.py"


cat > "$TEST" <<'PYTEST'
"""
Certification Self Validation Verification
"""


def test_self_validator_import():

    from wlplatform.certification.self_validation import (
        CertificationSelfValidator
    )

    assert CertificationSelfValidator



def test_validation_passes():

    from wlplatform.certification.self_validation import (
        CertificationSelfValidator
    )


    result = CertificationSelfValidator(
        "."
    ).validate()


    assert (
        result["status"]
        ==
        "PASS"
    )



def test_checks_exist():

    from wlplatform.certification.self_validation import (
        CertificationSelfValidator
    )


    result = CertificationSelfValidator(
        "."
    ).validate()


    assert len(
        result["checks"]
    ) >= 3
PYTEST


echo
echo "Running self-validation verification..."

python3 -m pytest \
"$TEST" \
-v


echo
echo "Certification Self-Validation Engine PASS"
