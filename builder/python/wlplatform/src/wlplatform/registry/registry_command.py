from wlplatform.registry.registry_service import RegistryService


def execute(root, command, package=None):

    registry = RegistryService(
        root
    )

    if command == "verify-dependencies":

        return registry.verify_dependencies(
            package
        )


    if command == "rebuild":

        return registry.rebuild()


    if command == "inspect":

        return registry.inspect(
            package
        )


    if command == "certify":

        return registry.certify()

    if command == "verify-graph":

        return registry.verify_graph()

    if command == "validate":

        return registry.validate()


    if command == "verify-chain":

        return registry.verify_chain()


    if command == "verify-hash":

        return registry.verify_hash()


    if command == "snapshot":

        return registry.snapshot()


    raise SystemExit(
        f"unsupported registry command: {command}"
    )
