import json
import hashlib
from pathlib import Path
from datetime import datetime, timezone

from .errors import JsonSyntaxError


def load_artifact(path, schema=None):
    artifact_path = Path(path)

    if not artifact_path.exists():
        raise FileNotFoundError(str(artifact_path))

    try:
        raw = artifact_path.read_bytes()

        digest = hashlib.sha256(raw).hexdigest()

        data = json.loads(raw.decode("utf-8"))

    except Exception as exc:
        raise JsonSyntaxError(
            f"Invalid JSON artifact: {artifact_path}: {exc}"
        ) from exc

    return {
        "artifact": data,
        "metadata": {
            "path": str(artifact_path),
            "sha256": digest,
            "schema": schema,
            "validated": True,
            "loaded_at": datetime.now(
                timezone.utc
            ).isoformat()
        }
    }
