

class CertificationEvidence:


    def export(
        self,
        result
    ):

        return {

            "certification":
                result.export(),

            "trust":
                (
                    "CERTIFIED"
                    if result.certified
                    else
                    "REJECTED"
                )

        }
