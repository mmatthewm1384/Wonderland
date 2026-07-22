
FAILURE_POLICIES = {

    "runtime": {
        "action": "RECOVERY_REQUIRED",
        "severity": "HIGH"
    },

    "service": {
        "action": "RESTART",
        "severity": "MEDIUM"
    },

    "unknown": {
        "action": "STOP",
        "severity": "CRITICAL"
    }

}


def evaluate(component):

    return FAILURE_POLICIES.get(
        component,
        FAILURE_POLICIES["unknown"]
    )
