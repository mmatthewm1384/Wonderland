

class DriftRemediation:


    def create_plan(
        self,
        drift
    ):

        if drift.drift:

            return {

                "action":
                    drift.remediation,

                "approved":
                    False,

                "requires_policy":
                    True

            }


        return {

            "action":
                "NONE",

            "approved":
                True

        }
