"""
Oblivion Execution Intent v1.

Transforms an authorized CapabilityAttestation v2 into a
validated, side-effect-free execution intent.

Authorization and execution remain deliberately separate:

    CapabilityAttestation v2
            |
            v
    ExecutionIntent v1
            |
            v
    Method Router

This module does not execute capabilities, select providers,
modify runtime state, or perform external I/O.
"""

from __future__ import annotations

from copy import deepcopy
from datetime import datetime, timezone


class ExecutionIntent:
    """
    Construct and validate Oblivion Execution Intent v1 objects.
    """

    TYPE = "oblivion-execution-intent"
    SCHEMA_VERSION = 1

    def __init__(self, root=None):
        self.root = root

    @staticmethod
    def _utc_now() -> str:
        return datetime.now(timezone.utc).isoformat()

    @classmethod
    def create(
        cls,
        attestation: dict,
        action: str = "execute",
    ) -> dict:
        """
        Create an execution intent from a CapabilityAttestation v2.

        The source attestation must contain:

        - type == capability-attestation
        - schema_version == 2
        - subject.package
        - subject.capability
        - decision.status == GRANTED
        - authority.registry_index_sha256

        No execution or external mutation occurs.
        """

        cls.validate_attestation(attestation)

        subject = attestation["subject"]
        decision = attestation["decision"]
        authority = attestation["authority"]

        return {
            "type": cls.TYPE,
            "schema_version": cls.SCHEMA_VERSION,
            "generated": cls._utc_now(),
            "subject": {
                "package": subject["package"],
                "capability": subject["capability"],
            },
            "action": action,
            "authorization": {
                "status": decision["status"],
                "source": "registry-trust-v1",
                "attestation": deepcopy(attestation),
            },
            "authority": {
                "registry_index_sha256": authority[
                    "registry_index_sha256"
                ],
            },
            "execution": {
                "status": "PENDING",
            },
        }

    @classmethod
    def validate_attestation(cls, attestation: dict) -> None:
        """
        Validate the minimum CapabilityAttestation v2 contract.

        Raises RuntimeError on invalid input.
        """

        if not isinstance(attestation, dict):
            raise RuntimeError(
                "Capability attestation must be an object"
            )

        if attestation.get("type") != "capability-attestation":
            raise RuntimeError(
                "Invalid capability attestation type"
            )

        if attestation.get("schema_version") != 2:
            raise RuntimeError(
                "Unsupported capability attestation schema"
            )

        subject = attestation.get("subject")

        if not isinstance(subject, dict):
            raise RuntimeError(
                "Capability attestation subject missing"
            )

        if not subject.get("package"):
            raise RuntimeError(
                "Capability attestation package missing"
            )

        if not subject.get("capability"):
            raise RuntimeError(
                "Capability attestation capability missing"
            )

        decision = attestation.get("decision")

        if not isinstance(decision, dict):
            raise RuntimeError(
                "Capability attestation decision missing"
            )

        if decision.get("status") != "GRANTED":
            raise RuntimeError(
                "Capability is not authorized"
            )

        authority = attestation.get("authority")

        if not isinstance(authority, dict):
            raise RuntimeError(
                "Capability attestation authority missing"
            )

        digest = authority.get("registry_index_sha256")

        if not isinstance(digest, str) or not digest.startswith(
            "sha256:"
        ):
            raise RuntimeError(
                "Capability attestation registry authority invalid"
            )

    @classmethod
    def validate_intent(cls, intent: dict) -> dict:
        """
        Validate an Execution Intent v1.

        Returns a normalized copy of the intent.
        """

        if not isinstance(intent, dict):
            raise RuntimeError(
                "Execution intent must be an object"
            )

        if intent.get("type") != cls.TYPE:
            raise RuntimeError(
                "Invalid execution intent type"
            )

        if intent.get("schema_version") != cls.SCHEMA_VERSION:
            raise RuntimeError(
                "Unsupported execution intent schema"
            )

        subject = intent.get("subject")

        if not isinstance(subject, dict):
            raise RuntimeError(
                "Execution intent subject missing"
            )

        if not subject.get("package"):
            raise RuntimeError(
                "Execution intent package missing"
            )

        if not subject.get("capability"):
            raise RuntimeError(
                "Execution intent capability missing"
            )

        action = intent.get("action")

        if not isinstance(action, str) or not action:
            raise RuntimeError(
                "Execution intent action missing"
            )

        authorization = intent.get("authorization")

        if not isinstance(authorization, dict):
            raise RuntimeError(
                "Execution intent authorization missing"
            )

        if authorization.get("status") != "GRANTED":
            raise RuntimeError(
                "Execution intent authorization invalid"
            )

        if authorization.get("source") != "registry-trust-v1":
            raise RuntimeError(
                "Execution intent authorization source invalid"
            )

        attestation = authorization.get("attestation")

        cls.validate_attestation(attestation)

        execution = intent.get("execution")

        if not isinstance(execution, dict):
            raise RuntimeError(
                "Execution intent execution state missing"
            )

        if execution.get("status") != "PENDING":
            raise RuntimeError(
                "Execution intent must begin in PENDING state"
            )

        authority = intent.get("authority")

        if not isinstance(authority, dict):
            raise RuntimeError(
                "Execution intent authority missing"
            )

        digest = authority.get("registry_index_sha256")

        if not isinstance(digest, str) or not digest.startswith(
            "sha256:"
        ):
            raise RuntimeError(
                "Execution intent registry authority invalid"
            )

        if (
            digest
            != attestation["authority"]["registry_index_sha256"]
        ):
            raise RuntimeError(
                "Execution intent authority does not match attestation"
            )

        if (
            subject["package"]
            != attestation["subject"]["package"]
            or subject["capability"]
            != attestation["subject"]["capability"]
        ):
            raise RuntimeError(
                "Execution intent subject does not match attestation"
            )

        return deepcopy(intent)
