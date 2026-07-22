
POLICIES = {

    "runtime_failure": {

        "condition": "FAILED",

        "action": "RECOVER"

    },


    "healthy": {

        "condition": "HEALTHY",

        "action": "NONE"

    }

}


class AutomationPolicyEngine:


    def evaluate(self, observation):

        if observation.status == "FAILED":

            return POLICIES[
                "runtime_failure"
            ]

        return POLICIES[
            "healthy"
        ]
