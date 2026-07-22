from dataclasses import dataclass


@dataclass
class RuntimeStatus:

    state: str
    healthy: bool
    message: str


class RuntimeAdapter:
    """
    Runtime boundary.

    Lifecycle decides transitions.
    Runtime performs operations.
    """


    def start(self):

        return RuntimeStatus(
            state="RUNNING",
            healthy=True,
            message="Runtime started"
        )


    def stop(self):

        return RuntimeStatus(
            state="STOPPED",
            healthy=True,
            message="Runtime stopped"
        )


    def restart(self):

        return RuntimeStatus(
            state="RUNNING",
            healthy=True,
            message="Runtime restarted"
        )


    def sleep(self):

        return RuntimeStatus(
            state="SLEEPING",
            healthy=True,
            message="Runtime sleeping"
        )


    def wake(self):

        return RuntimeStatus(
            state="RUNNING",
            healthy=True,
            message="Runtime awake"
        )


    def health(self):

        return RuntimeStatus(
            state="UNKNOWN",
            healthy=True,
            message="Runtime health check passed"
        )
