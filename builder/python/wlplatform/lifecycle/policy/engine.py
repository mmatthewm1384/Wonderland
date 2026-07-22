from .models import PolicyDecision


class LifecyclePolicyEngine:


    def __init__(
        self,
        evaluator,
        risk
    ):

        self.evaluator = evaluator

        self.risk = risk



    def evaluate(
        self,
        policy,
        observation
    ):

        matched = self.evaluator.evaluate(
            policy,
            observation
        )


        approved = (
            matched
            and
            self.risk.approved(
                policy.risk
            )
        )


        return PolicyDecision(

            approved=approved,

            action=policy.action,

            risk=policy.risk,

            policy=policy.name

        )
