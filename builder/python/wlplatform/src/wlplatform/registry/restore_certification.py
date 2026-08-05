from pathlib import Path
import json


class RestoreCertification:


    def __init__(self, root):

        self.root = Path(root)

        self.source = (
            self.root /
            "vault" /
            "08-Operations" /
            "evidence" /
            "registry" /
            "restore"
        )

        self.output = (
            self.root /
            "vault" /
            "08-Operations" /
            "certifications" /
            "registry" /
            "restore-certification.json"
        )


    def certify(self):

        records = sorted(
            self.source.glob("*.json")
        )

        if not records:

            raise RuntimeError(
                "No restore evidence"
            )


        latest = json.loads(
            records[-1].read_text()
        )


        certificate = {
            "schema_version": 1,
            "artifact":
                "registry-restore-certification",
            "status":
                "CERTIFIED",
            "transaction_id":
                latest["transaction_id"],
            "registry_hash":
                latest["registry_hash"],
            "operation":
                latest["operation"],
        }


        self.output.parent.mkdir(
            parents=True,
            exist_ok=True
        )


        self.output.write_text(
            json.dumps(
                certificate,
                indent=2
            )
        )


        return certificate
