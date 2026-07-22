"""
Certification Governance Engine Verification
"""

from pathlib import Path


def governance_path():

    return Path(
        "vault/08-Operations/"
        "governance/certification/"
        "certification-governance-v1.1.json"
    )



def test_governance_exists():

    assert governance_path().exists()



def test_governance_loads():

    from wlplatform.certification.governance import (
        CertificationGovernance
    )

    gov = CertificationGovernance.load(
        governance_path()
    )

    assert gov is not None



def test_governance_approved():

    from wlplatform.certification.governance import (
        CertificationGovernance
    )

    gov = CertificationGovernance.load(
        governance_path()
    )

    assert gov.approved() is True



def test_governance_has_owner():

    from wlplatform.certification.governance import (
        CertificationGovernance
    )

    gov = CertificationGovernance.load(
        governance_path()
    )

    assert (
        gov.owner()
        ==
        "Certification Engine"
    )
