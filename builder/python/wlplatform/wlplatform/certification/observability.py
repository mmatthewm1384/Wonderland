"""
Certification Observability Engine

Provides metrics, events, and health
visibility for certification lifecycle.
"""


from datetime import datetime, timezone


class CertificationObservability:


    def __init__(self):

        self.metrics = {

            "certifications": 0,

            "failures": 0,

            "recoveries": 0
        }


        self.events = []



    def record(
        self,
        event
    ):

        self.events.append(
            {
                "event":
                    event,

                "timestamp":
                    datetime.now(
                        timezone.utc
                    ).isoformat()
            }
        )


        if event == "CERTIFIED":

            self.metrics[
                "certifications"
            ] += 1


        elif event == "FAILED":

            self.metrics[
                "failures"
            ] += 1


        elif event == "RECOVERED":

            self.metrics[
                "recoveries"
            ] += 1



    def health(self):

        if self.metrics["failures"]:

            return "DEGRADED"


        return "HEALTHY"



    def snapshot(self):

        return {

            "engine":
                "certification",

            "health":
                self.health(),

            "metrics":
                self.metrics,

            "events":
                self.events
        }
