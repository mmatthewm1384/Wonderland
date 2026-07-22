"""
Certification Recovery Engine Verification
"""


def test_recovery_import():

    from wlplatform.certification.recovery import (
        CertificationRecovery
    )

    assert CertificationRecovery



def test_detect_missing_evidence():

    from wlplatform.certification.recovery import (
        CertificationRecovery
    )


    engine = CertificationRecovery()


    action = engine.diagnose(
        {
            "status": "FAILED",
            "checks": [
                {
                    "id":
                        "evidence-present",

                    "passed":
                        False
                }
            ]
        }
    )


    assert (
        action.failure
        ==
        "evidence-present"
    )



def test_recovery_recommendation():

    from wlplatform.certification.recovery import (
        CertificationRecovery
    )


    engine = CertificationRecovery()


    action = engine.diagnose(
        {
            "status": "FAILED",
            "checks": [
                {
                    "id":
                        "digest-valid",

                    "passed":
                        False
                }
            ]
        }
    )


    result = engine.recover(
        action
    )


    assert (
        result["action"]
        ==
        "REBUILD_DIGEST"
    )



def test_success_requires_no_action():

    from wlplatform.certification.recovery import (
        CertificationRecovery
    )


    engine = CertificationRecovery()


    action = engine.diagnose(
        {
            "status":
                "CERTIFIED"
        }
    )


    assert (
        action.status
        ==
        "COMPLETE"
    )
