from .models import LifecycleSnapshot


class LifecycleObserverEngine:


    def __init__(
        self,
        runtime,
        services,
        dependencies,
        certification
    ):

        self.runtime = runtime
        self.services = services
        self.dependencies = dependencies
        self.certification = certification



    def snapshot(self):

        return LifecycleSnapshot(

            runtime=self.runtime.observe(),

            services=self.services.observe(),

            dependencies=self.dependencies.observe(),

            certification=self.certification.observe()

        )
