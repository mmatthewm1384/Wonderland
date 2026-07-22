"""
Certification Policy Engine Verification
"""


from pathlib import Path


def policy_path():

    return Path(
        "vault/08-Operations/"
        "policies/certification/"
        "certification-policy-v1.1.json"
    )



def test_policy_exists():

    assert policy_path().exists()



def test_policy_loads():

    from wlplatform.certification.policy import (
        CertificationPolicy
    )

    policy = CertificationPolicy.load(
        policy_path()
    )

    assert len(
        policy.requirements()
    ) == 3



def test_policy_certifies_valid_state():

    from wlplatform.certification.policy import (
        CertificationPolicy
    )

    policy = CertificationPolicy.load(
        policy_path()
    )

    result = policy.evaluate(
        {
            "evidence": True,
            "integrity": True,
            "lineage": True
        }
    )


    assert (
        result["status"]
        ==
        "CERTIFIED"
    )



def test_policy_rejects_missing_evidence():

    from wlplatform.certification.policy import (
        CertificationPolicy
    )

    policy = CertificationPolicy.load(
        policy_path()
    )


    result = policy.evaluate(
        {
            "integrity": True,
            "lineage": True
        }
    )


    assert (
        result["status"]
        ==
        "FAILED"
    )
