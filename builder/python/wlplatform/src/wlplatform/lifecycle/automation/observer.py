from .models import Observation


class LifecycleObserver:


    def observe_runtime(self):

        return Observation(
            source="runtime",
            status="HEALTHY",
            details={
                "available": True
            }
        )


    def observe_services(self):

        return Observation(
            source="services",
            status="READY",
            details={
                "available": True
            }
        )
