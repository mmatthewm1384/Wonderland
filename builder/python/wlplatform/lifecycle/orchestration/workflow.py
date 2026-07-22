

class WorkflowManager:


    def advance(
        self,
        context,
        stage
    ):

        context.stages.append(
            stage
        )

        return context
