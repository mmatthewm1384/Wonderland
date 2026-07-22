from wlplatform.ecology import EcologyController


class EcologyLifecycle:

    def __init__(self):
        self.ecology = EcologyController()


    def rest(self):
        return self.ecology.transition(
            "RESTING"
        )


    def dream(self):
        return self.ecology.transition(
            "DREAM"
        )


    def sanctuary(self):
        return self.ecology.transition(
            "SANCTUARY"
        )


    def wake(self):

        state = self.ecology.status()["state"]

        if state != "ACTIVE":
            return self.ecology.transition(
                "ACTIVE"
            )

        return self.ecology.status()


    def sleep(self):
        return self.rest()
