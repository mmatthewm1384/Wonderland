from .rebuild import RegistryRebuilder


def execute(root):

    return RegistryRebuilder(
        root
    ).rebuild()
