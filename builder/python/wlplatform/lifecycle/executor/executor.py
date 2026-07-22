from .transaction import TransactionManager
from .evidence import ExecutionEvidence


class LifecycleAutomationExecutor:


    def __init__(
        self,
        controller
    ):

        self.controller = controller

        self.transactions = (
            TransactionManager()
        )

        self.evidence = (
            ExecutionEvidence()
        )



    def execute(
        self,
        plan
    ):

        transaction = (
            self.transactions.start(plan)
        )


        try:

            for step in plan.steps:

                result = (
                    self.controller.execute(
                        step.operation
                    )
                )


                transaction.steps_completed.append(
                    result
                )


            self.transactions.complete(
                transaction
            )


        except Exception:

            self.transactions.fail(
                transaction
            )


        return self.evidence.capture(
            transaction
        )
