
class CertificationValidator:


    def validate(
        self,
        evidence
    ):

        return {

            "verified":
                evidence.get(
                    "verified",
                    False
                ),

            "policy_validated":
                evidence.get(
                    "policy_validated",
                    False
                ),

            "execution_recorded":
                evidence.get(
                    "execution_recorded",
                    False
                )
        }
