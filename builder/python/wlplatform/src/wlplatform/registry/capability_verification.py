import json
import hashlib


class CapabilityAttestationVerifier:

    def __init__(
        self,
        root,
    ):
        self.root = root

        self.attestation_path = (
            root
            / "vault"
            / "08-Operations"
            / "evidence"
            / "capability-attestation"
            / "latest.json"
        )

        self.registry_index = (
            root
            / "vault"
            / "05-Registry"
            / "auto-drop"
            / "package-index.json"
        )


    def registry_digest(self):

        if not self.registry_index.exists():

            raise RuntimeError(
                "Registry index missing"
            )


        digest = hashlib.sha256(
            self.registry_index.read_bytes()
        ).hexdigest()


        return (
            "sha256:"
            + digest
        )


    def verify(self):

        if not self.attestation_path.exists():

            raise RuntimeError(
                "Capability attestation missing"
            )


        data = json.loads(
            self.attestation_path.read_text()
        )


        required = [
            "type",
            "schema_version",
            "subject",
            "decision",
            "authority",
        ]


        missing = [
            field
            for field in required
            if field not in data
        ]


        if missing:

            return {
                "status": "INVALID",
                "reason": "Missing attestation fields",
                "missing": missing,
            }


        if data["type"] != (
            "capability-attestation"
        ):

            return {
                "status": "INVALID",
                "reason": "Invalid attestation type",
            }


        if data["schema_version"] != 2:

            return {
                "status": "INVALID",
                "reason": "Unsupported schema version",
            }


        decision = data["decision"]


        if decision.get("status") != "GRANTED":

            return {
                "status": "INVALID",
                "reason": "Capability not granted",
            }


        expected_digest = (
            data["authority"]
            .get(
                "registry_index_sha256"
            )
        )


        actual_digest = (
            self.registry_digest()
        )


        if expected_digest != actual_digest:

            return {
                "status": "INVALID",
                "reason": "Registry digest mismatch",
                "expected":
                    expected_digest,
                "actual":
                    actual_digest,
            }


        return {
            "status": "VERIFIED",

            "type":
                data["type"],

            "schema_version":
                data["schema_version"],

            "subject":
                data["subject"],

            "decision":
                decision,

            "authority":
                data["authority"],
        }
