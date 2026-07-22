

class RepairPlanner:


    def plan(
        self,
        decision
    ):

        if decision.action == "RECOVER":

            return {

                "steps": [

                    "capture-state",

                    "restart-service",

                    "verify-health"

                ]

            }


        return {

            "steps": [

                "notify-operator"

            ]

        }
