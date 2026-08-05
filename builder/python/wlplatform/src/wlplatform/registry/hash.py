from pathlib import Path
import hashlib
import json


class RegistryHasher:

    @staticmethod
    def hash_model(model):

        payload = json.dumps(
            model,
            sort_keys=True,
            separators=(",", ":")
        ).encode("utf-8")

        return hashlib.sha256(
            payload
        ).hexdigest()


    @staticmethod
    def hash_registry(path):

        path = Path(path)

        data = json.loads(
            path.read_text()
        )

        return RegistryHasher.hash_model(
            data
        )
