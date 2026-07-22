from .models import DriftResult


class DriftAnalyzer:


    def analyze(
        self,
        component,
        desired,
        actual
    ):

        matches = (
            desired == actual
        )


        if matches:

            return DriftResult(

                component=component,

                desired=desired,

                actual=actual,

                drift=False,

                severity="NONE",

                remediation="NONE"

            )


        return DriftResult(

            component=component,

            desired=desired,

            actual=actual,

            drift=True,

            severity="HIGH",

            remediation="RECOVER"

        )
