from wlplatform.lifecycle.healing.engine import (
    SelfHealingEngine
)

from wlplatform.lifecycle.healing.analyzer import (
    FailureAnalyzer
)

from wlplatform.lifecycle.healing.decision import (
    HealingDecisionEngine
)

from wlplatform.lifecycle.healing.planner import (
    RepairPlanner
)



def test_self_healing():

    engine = SelfHealingEngine(

        FailureAnalyzer(),

        HealingDecisionEngine(),

        RepairPlanner()

    )


    result = engine.evaluate(
        "SERVICE_DOWN"
    )


    assert (
        result["decision"]["recoverable"]
        is True
    )


    assert (
        result["decision"]["action"]
        ==
        "RECOVER"
    )
