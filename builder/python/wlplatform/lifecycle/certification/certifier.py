from .models import CertificationResult


class LifecycleCertificationEngine:


    def certify(
        self,
        validation
    ):

        certified = all(
            validation.values()
        )


        return CertificationResult(

            engine=
                "lifecycle-automation",

            verified=
                validation[
                    "verified"
                ],

            policy_validated=
                validation[
                    "policy_validated"
                ],

            execution_recorded=
                validation[
                    "execution_recorded"
                ],

            certified=
                certified

        )
