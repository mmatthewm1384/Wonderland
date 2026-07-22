from wlplatform.lifecycle.policy.models import (
    LifecyclePolicy
)

from wlplatform.lifecycle.policy.registry import (
    PolicyRegistry
)

from wlplatform.lifecycle.policy.evaluator import (
    PolicyEvaluator
)

from wlplatform.lifecycle.policy.risk import (
    RiskEngine
)

from wlplatform.lifecycle.policy.engine import (
    LifecyclePolicyEngine
)


class Observation:

    status = "FAILED"



def test_policy_decision():

    policy = LifecyclePolicy(

        name="runtime-recovery",

        version="1.0",

        trigger="runtime",

        condition="FAILED",

        action="RECOVER",

        risk="HIGH"

    )


    engine = LifecyclePolicyEngine(

        PolicyEvaluator(),

        RiskEngine()

    )


    result = engine.evaluate(

        policy,

        Observation()

    )


    assert result.approved is True

    assert result.action == "RECOVER"
