"""
PRISMX Source Resolver
"""


class PrismResolver:


    def __init__(self, registry):

        self.registry = registry


    def resolve(self, identifier):

        stream = self.registry.resolve(
            identifier
        )

        return {
            "name": stream.name,
            "source": stream.source,
            "protocol": stream.protocol
        }
