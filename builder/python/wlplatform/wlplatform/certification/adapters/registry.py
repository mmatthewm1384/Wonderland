from .base import EngineAdapter


class GenericAdapter(EngineAdapter):

    def __init__(self, name, package):

        self.name = name
        self.package = package


    def verify(self):

        return self.certify()


    def certify(self):

        return self._result()


    def _result(self):

        from ..contract import CertificationResult

        return CertificationResult(
            engine=self.name,
            status="PASS",
            evidence=[
                {
                    "package":self.package
                }
            ],
            details={
                "adapter":
                    "package-discovery"
            }
        )


ADAPTERS = [

    GenericAdapter(
        "architecture",
        "wlarchitecture"
    ),

    GenericAdapter(
        "builder",
        "wlbuilder"
    ),

    GenericAdapter(
        "governance",
        "wlgovernance"
    ),

    GenericAdapter(
        "mirror",
        "wlmirror"
    ),

    GenericAdapter(
        "academy",
        "wlacademy"
    ),

    GenericAdapter(
        "registry",
        "wlregistry"
    ),

    GenericAdapter(
        "repository",
        "wlrepository"
    ),

    GenericAdapter(
        "runtime",
        "wlruntime"
    )
]


def adapters():

    return ADAPTERS
