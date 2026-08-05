from pathlib import Path
import hashlib
import json
import shutil
from datetime import datetime, timezone


class RegistrySnapshotService:


    def __init__(self, root):

        self.root = Path(root)

        self.registry = (
            self.root /
            "vault" /
            "05-Registry" /
            "auto-drop" /
            "package-index.json"
        )

        self.snapshot_dir = (
            self.root /
            "vault" /
            "05-Registry" /
            "snapshots"
        )

        self.backup_dir = (
            self.root /
            "vault" /
            "05-Registry" /
            "backups"
        )


    def hash_payload(self, payload):

        return hashlib.sha256(
            json.dumps(
                payload,
                sort_keys=True
            ).encode()
        ).hexdigest()


    def snapshots(self):

        if not self.snapshot_dir.exists():

            return {
                "snapshots": []
            }


        result = []

        for item in sorted(
            self.snapshot_dir.glob("*.json")
        ):

            result.append(
                json.loads(
                    item.read_text()
                )
            )


        return {
            "snapshots": result
        }



    def verify(self, snapshot_hash):

        target = (
            self.snapshot_dir /
            f"{snapshot_hash}.json"
        )


        if not target.exists():

            return {
                "passed": False,
                "reason":
                    "snapshot missing"
            }


        snapshot = json.loads(
            target.read_text()
        )


        payload = dict(snapshot)

        stored = payload.pop(
            "snapshot_hash",
            None
        )


        calculated = self.hash_payload(
            payload
        )


        return {
            "passed":
                stored == calculated,

            "snapshot":
                snapshot_hash,

            "issues":
                []
                if stored == calculated
                else [
                    "hash mismatch"
                ]
        }



    def restore(self, snapshot_hash):

        verification = self.verify(
            snapshot_hash
        )


        if not verification["passed"]:

            raise RuntimeError(
                json.dumps(
                    verification,
                    indent=2
                )
            )


        snapshot_file = (
            self.snapshot_dir /
            f"{snapshot_hash}.json"
        )


        snapshot = json.loads(
            snapshot_file.read_text()
        )


        registry_hash = snapshot.get(
            "registry_hash"
        )


        if not self.registry.exists():

            raise RuntimeError(
                "registry missing"
            )


        self.backup_dir.mkdir(
            parents=True,
            exist_ok=True
        )


        backup = (
            self.backup_dir /
            f"package-index-{datetime.now(timezone.utc).isoformat()}.json"
        )


        shutil.copy2(
            self.registry,
            backup
        )


        restore_record = {
            "schema_version": 1,

            "artifact":
                "registry-restore",

            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat(),

            "snapshot":
                snapshot_hash,

            "registry_hash":
                registry_hash,

            "backup":
                str(
                    backup.relative_to(
                        self.root
                    )
                )
        }


        output = (
            self.backup_dir /
            f"restore-{snapshot_hash}.json"
        )


        output.write_text(
            json.dumps(
                restore_record,
                indent=2
            )
        )


        return restore_record
