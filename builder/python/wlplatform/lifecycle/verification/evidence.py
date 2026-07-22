

class VerificationEvidence:


    def capture(
        self,
        result
    ):

        return {

            "verification":
                result.export(),

            "certification_ready":
                result.verified

        }
