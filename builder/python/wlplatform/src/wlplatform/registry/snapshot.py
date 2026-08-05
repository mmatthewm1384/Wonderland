from pathlib import Path
import hashlib
import json
from datetime import datetime, timezone


class RegistrySnapshot:


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


    def hash_file(self, path):

        return hashlib.sha256(
            path.read_bytes()
        ).hexdigest()


    def latest(self):

        if not self.snapshot_dir.exists():

            return None


        files = sorted(
            self.snapshot_dir.glob(
                "*.json"
            )
        )

        if not files:

            return None


        return json.loads(
            files[-1].read_text()
        )


    def create(self):

        if not self.registry.exists():

            raise RuntimeError(
                "registry index missing"
            )


        self.snapshot_dir.mkdir(
            parents=True,
            exist_ok=True
        )


        registry_hash = self.hash_file(
            self.registry
        )


        previous = self.latest()


        snapshot = {

            "schema_version": 1,

            "artifact":
                "registry-snapshot",

            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat(),

            "registry_hash":
                registry_hash,

            "packages":
                len(
                    json.loads(
                        self.registry.read_text()
                    ).get(
                        "packages",
                        {}
                    )
                ),

            "previous_snapshot_hash":
                (
                    previous.get(
                        "snapshot_hash"
                    )
                    if previous
                    else None
                )
        }


        snapshot["snapshot_hash"] = (
            hashlib.sha256(
                json.dumps(
                    snapshot,
                    sort_keys=True
                ).encode()
            ).hexdigest()
        )


        output = (
            self.snapshot_dir /
            f"{snapshot['snapshot_hash']}.json"
        )


        output.write_text(
            json.dumps(
                snapshot,
                indent=2
            )
        )


        return snapshot
