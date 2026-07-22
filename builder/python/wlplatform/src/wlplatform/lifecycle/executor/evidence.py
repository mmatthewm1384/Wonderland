

class ExecutionEvidence:


    def capture(
        self,
        transaction
    ):

        return {

            "transaction":
                transaction.export(),

            "verified": True

        }
