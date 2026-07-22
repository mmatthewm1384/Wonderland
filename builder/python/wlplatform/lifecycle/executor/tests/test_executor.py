from wlplatform.lifecycle.executor.executor import (
    LifecycleAutomationExecutor
)


class Controller:


    def execute(
        self,
        action
    ):

        return action



class Step:

    operation = "start-runtime"



class Plan:

    steps = [
        Step()
    ]



def test_execution():

    executor = LifecycleAutomationExecutor(
        Controller()
    )


    result = executor.execute(
        Plan()
    )


    assert result["verified"] is True

    assert (
        result["transaction"]["status"]
        ==
        "COMPLETE"
    )
