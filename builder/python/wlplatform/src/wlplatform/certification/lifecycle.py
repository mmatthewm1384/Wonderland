"""
Certification Lifecycle Controller

Coordinates certification lifecycle states.
"""


from datetime import datetime, timezone


class LifecycleState:

    INITIALIZED = "INITIALIZED"

    ASSESSING = "ASSESSING"

    VALIDATING = "VALIDATING"

    CERTIFIED = "CERTIFIED"

    FAILED = "FAILED"

    RECOVERING = "RECOVERING"

    REVALIDATING = "REVALIDATING"

    EXPLAINED = "EXPLAINED"



class CertificationLifecycle:


    def __init__(self):

        self.state = (
            LifecycleState.INITIALIZED
        )

        self.history = []



    def transition(
        self,
        state
    ):

        self.state = state

        self.history.append(
            {
                "state":
                    state,

                "timestamp":
                    datetime.now(
                        timezone.utc
                    ).isoformat()
            }
        )

        return self.state



    def assess(self):

        return self.transition(
            LifecycleState.ASSESSING
        )



    def validate(self):

        return self.transition(
            LifecycleState.VALIDATING
        )



    def certify(self):

        return self.transition(
            LifecycleState.CERTIFIED
        )



    def explain(self):

        return self.transition(
            LifecycleState.EXPLAINED
        )



    def fail(self):

        return self.transition(
            LifecycleState.FAILED
        )



    def recover(self):

        return self.transition(
            LifecycleState.RECOVERING
        )



    def revalidate(self):

        return self.transition(
            LifecycleState.REVALIDATING
        )
