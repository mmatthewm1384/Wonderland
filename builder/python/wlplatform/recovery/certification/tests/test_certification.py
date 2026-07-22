from wlplatform.recovery.certification.evaluator import certify


def test_recovery_certification():

    result = certify()

    assert result.certified is True
    assert len(result.controls) == 5
