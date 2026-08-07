import hashlib
import json
from pathlib import Path
from datetime import datetime, timezone


class CapabilityAdmission:

    def __init__(self, root):

        self.root = Path(root)

        self.capability_file = (
            self.root
            / "vault"
            / "05-Registry"
            / "capabilities.json"
        )

        self.registry_index = (
            self.root
            / "vault"
            / "05-Registry"
            / "auto-drop"
            / "package-index.json"
        )

        self.evidence_dir = (
            self.root
            / "vault"
            / "08-Operations"
            / "evidence"
            / "capability-attestation"
        )


    def registry_digest(self):
    
        if not self.registry_index.exists():
    
            return (
                "sha256:unavailable"
            )
    
    
        digest = hashlib.sha256(
            self.registry_index.read_bytes()
        ).hexdigest()
    
    
        return (
            "sha256:"
            + digest
        )


    def evaluate(
        self,
        package,
        capability,
    ):

        if not self.capability_file.exists():

            return {
                "status": "DENIED",
                "package": package,
                "capability": capability,
                "reason": "Capability registry missing",
            }


        data = json.loads(
            self.capability_file.read_text()
        )


        allowed = data.get(
            "capabilities",
            {},
        )


        if capability not in allowed.get(
            package,
            [],
        ):

            return {
                "status": "DENIED",
                "package": package,
                "capability": capability,
                "reason": "Capability not authorized",
            }


        return {
            "status": "GRANTED",
            "package": package,
            "capability": capability,
            "reason": "Capability authorized",
        }


    def write_attestation(
        self,
        package,
        capability,
        decision,
    ):

        self.evidence_dir.mkdir(
            parents=True,
            exist_ok=True,
        )


        attestation = {
            "type":
                "capability-attestation",

            "schema_version":
                2,

            "generated":
                datetime.now(
                    timezone.utc
                ).isoformat(),

            "subject": {
                "package":
                    package,

                "capability":
                    capability,
            },

            "decision": {
                "status":
                    decision["status"],
            
                "reason":
                    decision.get(
                        "reason"
                    ),
            },

            "authority": {
                "registry_index_sha256":
                    self.registry_digest(),
            },
        }


        path = (
            self.evidence_dir
            / "latest.json"
        )


        path.write_text(
            json.dumps(
                attestation,
                indent=2,
            )
        )


        return attestation


    def request(
        self,
        package,
        capability,
    ):

        decision = self.evaluate(
            package,
            capability,
        )


        evidence = self.write_attestation(
            package,
            capability,
            decision,
        )


        if decision["status"] != "GRANTED":

            raise RuntimeError(
                json.dumps(
                    decision,
                    indent=2,
                )
            )


        return {
            **evidence,
            "certificate": str(
                self.evidence_dir
                / "latest.json"
            ),
        }
