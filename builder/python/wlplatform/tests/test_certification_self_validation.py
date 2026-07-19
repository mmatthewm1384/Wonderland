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
