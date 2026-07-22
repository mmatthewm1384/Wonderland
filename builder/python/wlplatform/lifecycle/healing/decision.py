from .models import HealingDecision


class HealingDecisionEngine:


    def decide(
        self,
        analysis
    ):

        if analysis["recoverable"]:

            return HealingDecision(

                failure_type=
                    analysis["failure"],

                recoverable=True,

                action="RECOVER",

                risk="MEDIUM"

            )


        return HealingDecision(

            failure_type=
                analysis["failure"],

            recoverable=False,

            action="ESCALATE",

            risk="HIGH"

        )
