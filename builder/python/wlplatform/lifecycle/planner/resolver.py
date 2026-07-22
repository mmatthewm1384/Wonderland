
class DependencyResolver:


    def resolve(
        self,
        action
    ):

        if action == "RECOVER":

            return [

                "stop-failed-service",

                "restore-runtime",

                "verify-runtime"

            ]


        if action == "RESTART":

            return [

                "stop-runtime",

                "start-runtime",

                "verify-runtime"

            ]


        return []
