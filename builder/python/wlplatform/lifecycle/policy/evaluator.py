
class PolicyEvaluator:


    def evaluate(
        self,
        policy,
        observation
    ):

        if (
            observation.status
            ==
            policy.condition
        ):

            return True


        return False
