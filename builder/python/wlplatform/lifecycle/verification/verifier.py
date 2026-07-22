from .models import VerificationResult


class LifecycleVerificationEngine:


    def verify(
        self,
        expected,
        actual
    ):

        success = (
            expected == actual
        )


        return VerificationResult(

            expected=expected,

            actual=actual,

            verified=success,

            result=(
                "PASS"
                if success
                else
                "FAIL"
            ),

            recovery_required=(
                not success
            )

        )
