from wlplatform.lifecycle.controller import (
    LifecycleController
)

from wlplatform.lifecycle.states import (
    LifecycleState
)


def test_startup_flow():

    controller = LifecycleController()

    controller.transition(
        LifecycleState.INITIALIZING
    )

    controller.transition(
        LifecycleState.READY
    )

    controller.transition(
        LifecycleState.RUNNING
    )

    assert (
        controller.state
        ==
        LifecycleState.RUNNING
    )


def test_invalid_transition():

    controller = LifecycleController()

    try:

        controller.transition(
            LifecycleState.RUNNING
        )

        assert False

    except RuntimeError:

        assert True
