from .models import (
    ActionStep,
    ExecutionPlan
)


class LifecycleActionPlanner:


    def __init__(
        self,
        resolver,
        rollback
    ):

        self.resolver = resolver

        self.rollback = rollback



    def create_plan(
        self,
        action
    ):

        operations = self.resolver.resolve(
            action
        )


        steps = []

        for index, operation in enumerate(
            operations,
            start=1
        ):

            steps.append(

                ActionStep(

                    name=operation,

                    operation=operation,

                    target="lifecycle",

                    order=index

                )

            )


        return ExecutionPlan(

            action=action,

            steps=steps,

            rollback=self.rollback.create(
                action
            )

        )
