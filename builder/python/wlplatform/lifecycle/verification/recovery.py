

class VerificationRecoveryBridge:


    def evaluate(
        self,
        result
    ):

        if result.recovery_required:

            return {
                "action":
                    "RECOVERY_REQUIRED"
            }


        return {
            "action":
                "NONE"
        }
