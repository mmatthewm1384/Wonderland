"""
PRISMX Security Manager
"""

from .trust import PrismTrustEngine
from .authorization import PrismAuthorization


class PrismSecurityManager:


    def __init__(self):

        self.trust = PrismTrustEngine()
        self.authorization = PrismAuthorization()


    def verify(
        self,
        identity
    ):

        return self.trust.evaluate(
            identity
        )


    def authorize(
        self,
        identity,
        permission
    ):

        return self.authorization.check(
            identity,
            permission
        )
