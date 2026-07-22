"""
PRISMX Trust Evaluation
"""


class PrismTrustEngine:


    def evaluate(
        self,
        identity
    ):

        if not identity.fingerprint:

            return {
                "trusted": False,
                "reason": "missing identity"
            }


        return {
            "trusted": True,
            "fingerprint":
                identity.fingerprint
        }
