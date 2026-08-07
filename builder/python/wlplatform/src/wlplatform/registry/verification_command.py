from wlplatform.registry.verification import (
    RegistryVerification,
)


def execute(root):
    return RegistryVerification(
        root
    ).verify()
