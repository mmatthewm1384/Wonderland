from .states import LifecycleState


ALLOWED = {

    LifecycleState.UNKNOWN: [
        LifecycleState.INITIALIZING
    ],

    LifecycleState.INITIALIZING: [
        LifecycleState.READY
    ],

    LifecycleState.READY: [
        LifecycleState.RUNNING,
        LifecycleState.STOPPED
    ],

    LifecycleState.RUNNING: [
        LifecycleState.SLEEPING,
        LifecycleState.STOPPING,
        LifecycleState.RECOVERY_REQUIRED
    ],

    LifecycleState.SLEEPING: [
        LifecycleState.RUNNING,
        LifecycleState.STOPPING
    ],

    LifecycleState.STOPPING: [
        LifecycleState.STOPPED
    ],

    LifecycleState.RECOVERY_REQUIRED: [
        LifecycleState.RECOVERING
    ],

    LifecycleState.RECOVERING: [
        LifecycleState.READY
    ]
}


def can_transition(current, target):

    return target in ALLOWED.get(
        current,
        []
    )
