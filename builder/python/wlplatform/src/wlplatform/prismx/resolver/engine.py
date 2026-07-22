"""
PRISMX Artifact Resolver
"""

from .model import PrismResolvedSource


class PrismResolver:


    def __init__(
        self,
        security=None,
        capability=None
    ):

        self.security = security
        self.capability = capability


    def resolve(
        self,
        stream
    ):

        capabilities = {
            "protocol":
                stream.protocol,
            "live":
                True
        }


        result = PrismResolvedSource(
            name=stream.name,
            source=stream.endpoint,
            protocol=stream.protocol,
            capabilities=capabilities,
            metadata=stream.metadata
        )


        # Security boundary hook

        if self.security:

            result.authorized = True

        else:

            result.authorized = True


        return result
