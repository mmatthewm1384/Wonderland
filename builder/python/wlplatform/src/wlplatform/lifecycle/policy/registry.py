from .models import LifecyclePolicy


class PolicyRegistry:


    def __init__(self):

        self.policies = {}



    def register(self, policy):

        self.policies[
            policy.name
        ] = policy



    def get(self, name):

        return self.policies.get(
            name
        )
