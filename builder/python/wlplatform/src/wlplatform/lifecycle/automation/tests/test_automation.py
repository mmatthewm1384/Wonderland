from wlplatform.lifecycle.automation.observer import (
    LifecycleObserver
)

from wlplatform.lifecycle.automation.policy import (
    AutomationPolicyEngine
)

from wlplatform.lifecycle.automation.planner import (
    ActionPlanner
)


def test_automation_flow():

    observer = LifecycleObserver()

    policy = AutomationPolicyEngine()

    planner = ActionPlanner()


    observation = (
        observer.observe_runtime()
    )


    decision = policy.evaluate(
        observation
    )


    request = planner.create_plan(
        observation,
        decision
    )


    assert request.action == "NONE"



def test_failure_policy():

    from wlplatform.lifecycle.automation.models import (
        Observation
    )

    observation = Observation(
        source="runtime",
        status="FAILED",
        details={}
    )


    decision = (
        AutomationPolicyEngine()
        .evaluate(observation)
    )


    assert decision["action"] == "RECOVER"
