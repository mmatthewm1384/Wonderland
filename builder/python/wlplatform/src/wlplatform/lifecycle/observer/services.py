from .models import LifecycleSignal


class ServiceObserver:


    def observe(self):

        return LifecycleSignal(

            source="services",

            status="READY",

            healthy=True,

            metadata={
                "services": []
            }
        )
