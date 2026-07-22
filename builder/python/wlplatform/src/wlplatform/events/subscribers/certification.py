from ..subscriber import EventSubscriber


class CertificationSubscriber(
    EventSubscriber
):

    name = "certification"


    def handles(
        self,
        event
    ):

        return event["event_type"] in {
            "ENGINE_PACKAGE_VERIFIED",
            "ENGINE_TESTS_COMPLETED",
        }


    def process(
        self,
        event
    ):

        return {
            "subscriber": self.name,
            "action": "certification_review",
            "engine": event["engine"],
        }
