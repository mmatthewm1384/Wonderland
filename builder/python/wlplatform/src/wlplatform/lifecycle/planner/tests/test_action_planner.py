from wlplatform.lifecycle.planner.planner import (
    LifecycleActionPlanner
)

from wlplatform.lifecycle.planner.resolver import (
    DependencyResolver
)

from wlplatform.lifecycle.planner.rollback import (
    RollbackPlanner
)



def test_recovery_plan():

    planner = LifecycleActionPlanner(

        DependencyResolver(),

        RollbackPlanner()

    )


    plan = planner.create_plan(
        "RECOVER"
    )


    assert len(plan.steps) == 3

    assert plan.rollback["enabled"] is True
