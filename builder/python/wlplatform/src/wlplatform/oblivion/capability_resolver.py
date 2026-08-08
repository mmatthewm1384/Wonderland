from wlplatform.registry.registry_service import RegistryService


class CapabilityResolver:
    """
    Oblivion's capability-resolution boundary.

    Registry Trust remains authoritative.
    Oblivion consumes and validates the resulting
    CapabilityAttestation v2.
    """

    def __init__(self, root):
        self.root = root

    def resolve(
        self,
        package,
        capability,
    ):
        if not package:
            raise RuntimeError(
                "Package required"
            )

        if not capability:
            raise RuntimeError(
                "Capability required"
            )

        attestation = RegistryService(
            self.root
        ).capability_request(
            package,
            capability,
        )

        if not isinstance(
            attestation,
            dict,
        ):
            raise RuntimeError(
                "Invalid capability attestation"
            )

        if attestation.get("type") != (
            "capability-attestation"
        ):
            raise RuntimeError(
                "Invalid capability attestation type"
            )

        if attestation.get(
            "schema_version"
        ) != 2:
            raise RuntimeError(
                "Unsupported capability attestation schema"
            )

        subject = attestation.get(
            "subject",
            {},
        )

        if subject.get("package") != package:
            raise RuntimeError(
                "Capability attestation package mismatch"
            )

        if subject.get(
            "capability"
        ) != capability:
            raise RuntimeError(
                "Capability attestation capability mismatch"
            )

        decision = attestation.get(
            "decision",
            {},
        )

        if decision.get(
            "status"
        ) != "GRANTED":
            raise RuntimeError(
                "Capability not authorized"
            )

        return {
            "status": "AUTHORIZED",
            "package": package,
            "capability": capability,
            "source": "registry-trust-v1",
            "attestation": attestation,
        }
