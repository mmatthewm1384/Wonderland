from wlplatform.registry.registry_service import RegistryService


def execute(
    root,
    action,
    package=None,
    args=None,
):
    registry = RegistryService(root)

    args = args or []

    if action == "certify":
        return registry.certify()

    if action == "verify":
        return registry.verify()

    if action == "validate":
        return registry.validate()

    if action == "capability":

        if not package or not args:
            raise RuntimeError(
                "Usage: wl registry capability <package> <capability>"
            )

        return registry.capability_request(
            package,
            args[0],
        )

    if action == "capability-verify":
        return registry.capability_verify()

    raise RuntimeError(
        f"Unknown registry action: {action}"
    )
