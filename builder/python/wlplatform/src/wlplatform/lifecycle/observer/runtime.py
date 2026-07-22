from .models import LifecycleSignal


class RuntimeObserver:


    def observe(self):

        return LifecycleSignal(

            source="runtime",

            status="READY",

            healthy=True,

            metadata={
                "engine": "runtime"
            }
        )
