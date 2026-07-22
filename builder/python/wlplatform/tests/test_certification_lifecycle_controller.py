"""
Certification Lifecycle Controller Verification
"""


def test_lifecycle_import():

    from wlplatform.certification.lifecycle import (
        CertificationLifecycle
    )

    assert CertificationLifecycle



def test_certification_flow():

    from wlplatform.certification.lifecycle import (
        CertificationLifecycle
    )


    lifecycle = CertificationLifecycle()


    lifecycle.assess()

    lifecycle.validate()

    lifecycle.certify()


    assert (
        lifecycle.state
        ==
        "CERTIFIED"
    )



def test_failure_recovery_flow():

    from wlplatform.certification.lifecycle import (
        CertificationLifecycle
    )


    lifecycle = CertificationLifecycle()


    lifecycle.fail()

    lifecycle.recover()

    lifecycle.revalidate()


    assert (
        lifecycle.state
        ==
        "REVALIDATING"
    )



def test_history_recorded():

    from wlplatform.certification.lifecycle import (
        CertificationLifecycle
    )


    lifecycle = CertificationLifecycle()

    lifecycle.certify()


    assert len(
        lifecycle.history
    ) == 1
