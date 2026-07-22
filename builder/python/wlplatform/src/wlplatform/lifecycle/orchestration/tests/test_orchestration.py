from wlplatform.lifecycle.orchestration.workflow import (
    WorkflowManager
)

from wlplatform.lifecycle.orchestration.orchestrator import (
    LifecycleOrchestrator
)



def test_orchestration_flow():

    orchestrator = LifecycleOrchestrator(
        WorkflowManager()
    )


    result = orchestrator.run(

        [

            "observe",

            "policy",

            "plan",

            "execute",

            "verify",

            "certify",

            "audit"

        ]

    )


    assert result.status == "COMPLETE"

    assert (
        len(result.stages)
        ==
        7
    )
