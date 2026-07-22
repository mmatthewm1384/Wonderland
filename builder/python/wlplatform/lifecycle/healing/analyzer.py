

class FailureAnalyzer:


    RECOVERABLE = {

        "SERVICE_DOWN",

        "RUNTIME_FAILURE",

        "FAILED_HEALTH_CHECK"

    }


    def analyze(
        self,
        failure
    ):

        return {

            "failure":
                failure,

            "recoverable":
                failure in self.RECOVERABLE

        }
