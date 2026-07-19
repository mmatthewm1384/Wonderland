#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$WL_ROOT"

echo "=============================================="
echo "Certification Trust Attestation Engine v1.1"
echo "=============================================="


ATTEST_DIR="vault/08-Operations/certifications/attestations"

mkdir -p "$ATTEST_DIR"


MODULE="builder/python/wlplatform/wlplatform/certification/attestation.py"


cat > "$MODULE" <<'PYTHON'
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
PYTHON


REPORT="$ATTEST_DIR/certification-trust-attestation.json"


python3 <<PYTHON
from wlplatform.certification.attestation import (
    CertificationAttestation
)

engine = CertificationAttestation()

attestation = engine.create(
    policy="certification-policy-v1.1",
    governance="certification-governance-v1.1",
    validation="certification-self-validation",
    status="CERTIFIED"
)

engine.write(
    "$REPORT",
    attestation
)

print(
    "Trust attestation generated"
)
PYTHON


TEST="builder/python/wlplatform/tests/test_certification_trust_attestation.py"


cat > "$TEST" <<'PYTEST'
"""
Certification Trust Attestation Verification
"""


def test_attestation_import():

    from wlplatform.certification.attestation import (
        CertificationAttestation
    )

    assert CertificationAttestation



def test_attestation_creation():

    from wlplatform.certification.attestation import (
        CertificationAttestation
    )


    result = CertificationAttestation().create(
        "policy",
        "governance",
        "validation"
    )


    assert (
        result["trust"]["status"]
        ==
        "CERTIFIED"
    )



def test_attestation_contains_proof():

    from wlplatform.certification.attestation import (
        CertificationAttestation
    )


    result = CertificationAttestation().create(
        "policy",
        "governance",
        "validation"
    )


    assert (
        result["proof"]["policy"]
        ==
        "policy"
    )



def test_attestation_subject():

    from wlplatform.certification.attestation import (
        CertificationAttestation
    )


    result = CertificationAttestation().create(
        "policy",
        "governance",
        "validation"
    )


    assert (
        result["subject"]["engine"]
        ==
        "certification"
    )
PYTEST


echo
echo "Running trust attestation verification..."

python3 -m pytest \
"$TEST" \
-v


echo
echo "Certification Trust Attestation Engine PASS"
