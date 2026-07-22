from .models import LifecycleSignal


class DependencyObserver:


    def observe(self):

        return LifecycleSignal(

            source="dependencies",

            status="RESOLVED",

            healthy=True,

            metadata={
                "graph": "valid"
            }
        )
