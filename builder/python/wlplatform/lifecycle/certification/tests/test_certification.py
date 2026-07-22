from wlplatform.lifecycle.certification.validator import (
    CertificationValidator
)

from wlplatform.lifecycle.certification.certifier import (
    LifecycleCertificationEngine
)



def test_certification_pass():

    evidence = {

        "verified": True,

        "policy_validated": True,

        "execution_recorded": True

    }


    validation = (
        CertificationValidator()
        .validate(
            evidence
        )
    )


    result = (
        LifecycleCertificationEngine()
        .certify(
            validation
        )
    )


    assert result.certified is True
