from .states import LifecycleState
from .transitions import can_transition


class LifecycleController:


    def __init__(self):

        self.state = LifecycleState.UNKNOWN


    def transition(self, target):

        if not can_transition(
            self.state,
            target
        ):

            raise RuntimeError(
                f"Invalid transition "
                f"{self.state.value} -> "
                f"{target.value}"
            )

        self.state = target

        return self.state


    def status(self):

        return self.state.value
