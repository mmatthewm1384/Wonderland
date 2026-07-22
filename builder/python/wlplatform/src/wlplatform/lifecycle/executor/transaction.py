from .models import ExecutionTransaction


class TransactionManager:


    def start(
        self,
        plan
    ):

        return ExecutionTransaction(

            plan_id=str(
                id(plan)
            ),

            status="RUNNING",

            steps_completed=[]

        )



    def complete(
        self,
        transaction
    ):

        transaction.status = "COMPLETE"

        return transaction



    def fail(
        self,
        transaction
    ):

        transaction.status = "FAILED"

        return transaction
