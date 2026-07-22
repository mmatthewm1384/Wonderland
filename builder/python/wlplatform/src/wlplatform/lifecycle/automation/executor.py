

class AutomationExecutor:


    def execute(self, request):

        if request.action == "NONE":

            return {
                "status": "NO_ACTION"
            }


        if request.action == "RECOVER":

            return {
                "status": "RECOVERY_REQUESTED"
            }


        return {
            "status": "UNKNOWN_ACTION"
        }
