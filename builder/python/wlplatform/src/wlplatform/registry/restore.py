from pathlib import Path
import json
from datetime import datetime, timezone
import shutil

from .hash import RegistryHasher
from wlplatform.services.transaction_service import TransactionService


class RegistryRestore:


    def __init__(self, root):

        self.root = Path(root)

        self.registry_index = (
            self.root /
            "vault" /
            "05-Registry" /
            "auto-drop" /
            "package-index.json"
        )

        self.backup_dir = (
            self.root /
            "vault" /
            "05-Registry" /
            "backups"
        )


    def restore(self, snapshot):

        snapshot_path = Path(snapshot)

        if not snapshot_path.is_absolute():

            snapshot_path = (
                self.root /
                snapshot
            )


        if not snapshot_path.exists():

            raise RuntimeError(
                "Snapshot missing"
            )


        data = json.loads(
            snapshot_path.read_text()
        )


        registry = data.get(
            "registry"
        )


        if registry is None:

            raise RuntimeError(
                "Invalid snapshot payload"
            )


        expected_hash = data.get(
            "registry_hash"
        )


        actual_hash = (
            RegistryHasher.hash_model(
                registry
            )
        )


        if expected_hash != actual_hash:

            raise RuntimeError(
                "Snapshot hash mismatch"
            )


        self.backup_dir.mkdir(
            parents=True,
            exist_ok=True
        )


        if self.registry_index.exists():

            backup = (
                self.backup_dir /
                f"package-index-{datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')}.json"
            )

            shutil.copy2(
                self.registry_index,
                backup
            )


        self.registry_index.write_text(
            json.dumps(
                registry,
                indent=2
            )
        )


        transaction = TransactionService(
            self.root
        ).create(
            "auto-drop-registry",
            "restore",
            {
                "snapshot":
                    str(snapshot_path),
                "registry_hash":
                    actual_hash,
            }
        )


        transaction = TransactionService(
            self.root
        ).complete(
            transaction["transaction_id"],
            {
                "status": "PASS",
                "registry_hash":
                    actual_hash,
            }
        )


        return {
            "status": "PASS",
            "restored_snapshot":
                str(snapshot_path),
            "registry_hash":
                actual_hash,
            "transaction_id":
                transaction["transaction_id"],
        }
