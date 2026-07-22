
class SelfHealingEngine:


    def __init__(
        self,
        analyzer,
        decision,
        planner
    ):

        self.analyzer = analyzer

        self.decision = decision

        self.planner = planner



    def evaluate(
        self,
        failure
    ):

        analysis = (
            self.analyzer.analyze(
                failure
            )
        )

        decision = (
            self.decision.decide(
                analysis
            )
        )

        plan = (
            self.planner.plan(
                decision
            )
        )

        return {

            "decision":
                decision.export(),

            "plan":
                plan

        }
