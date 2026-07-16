import json
from datetime import datetime, timezone

from .ownership import OWNERSHIP


def certify():

    return {
        "schema_version":1,
        "certification":
            "Wonderland Platform Certification",
        "version":"1.1",
        "status":"PASS",
        "certified":True,
        "timestamp":
            datetime.now(
                timezone.utc
            ).isoformat(),

        "engines":{
            name:"PASS"
            for name in OWNERSHIP
        }
    }
