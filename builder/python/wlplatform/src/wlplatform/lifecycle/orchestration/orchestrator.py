from .models import create_context


class LifecycleOrchestrator:


    def __init__(
        self,
        workflow
    ):

        self.workflow = workflow



    def run(
        self,
        stages
    ):

        context = create_context()


        for stage in stages:

            context = (
                self.workflow.advance(
                    context,
                    stage
                )
            )


        context.status = "COMPLETE"


        return context
