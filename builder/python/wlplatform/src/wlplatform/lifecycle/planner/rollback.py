
class RollbackPlanner:


    def create(
        self,
        action
    ):

        return {

            "enabled": True,

            "trigger": action,

            "strategy":
                "restore-last-known-good"

        }
