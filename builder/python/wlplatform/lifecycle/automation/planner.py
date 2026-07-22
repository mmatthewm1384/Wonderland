from .models import AutomationRequest


class ActionPlanner:


    def create_plan(
        self,
        observation,
        policy
    ):

        return AutomationRequest(

            trigger=observation.source,

            observation=observation.export(),

            policy=str(policy),

            action=policy["action"]

        )
