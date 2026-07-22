from wlplatform.lifecycle.verification.verifier import (
    LifecycleVerificationEngine
)


def test_verification_pass():

    result = (
        LifecycleVerificationEngine()
        .verify(
            "RUNNING",
            "RUNNING"
        )
    )

    assert result.verified is True

    assert result.result == "PASS"



def test_verification_failure():

    result = (
        LifecycleVerificationEngine()
        .verify(
            "RUNNING",
            "STOPPED"
        )
    )

    assert result.recovery_required is True
