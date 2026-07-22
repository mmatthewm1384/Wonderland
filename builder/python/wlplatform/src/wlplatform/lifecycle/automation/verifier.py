

class AutomationVerifier:


    def verify(self, result):

        return (
            result.get("status")
            !=
            "UNKNOWN_ACTION"
        )
