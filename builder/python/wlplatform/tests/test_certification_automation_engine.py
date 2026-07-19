"""
Certification Automation Engine Verification
"""


def test_automation_import():

    from wlplatform.certification.automation import (
        CertificationAutomation
    )

    assert CertificationAutomation



def test_workflow_execution():

    from wlplatform.certification.automation import (
        CertificationAutomation
    )


    engine = CertificationAutomation()


    result = engine.run(
        "validate"
    )


    assert (
        result["status"]
        ==
        "COMPLETED"
    )



def test_automation_enabled():

    from wlplatform.certification.automation import (
        CertificationAutomation
    )


    engine = CertificationAutomation()


    assert (
        engine.enabled()
        is True
    )
