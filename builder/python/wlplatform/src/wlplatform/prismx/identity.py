import hashlib
import json


def create_identity(data: dict):

    payload = json.dumps(
        data,
        sort_keys=True
    )

    return hashlib.sha256(
        payload.encode()
    ).hexdigest()
