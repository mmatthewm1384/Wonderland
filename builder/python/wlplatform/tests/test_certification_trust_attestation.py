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
