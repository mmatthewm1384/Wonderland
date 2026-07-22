from .models import LifecycleSignal


class CertificationObserver:


    def observe(self):

        return LifecycleSignal(

            source="certification",

            status="CERTIFIED",

            healthy=True,

            metadata={
                "trust": "CERTIFIED"
            }
        )
