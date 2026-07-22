import json
from pathlib import Path


def write_evidence(path, evidence):

    target = Path(path)

    target.parent.mkdir(
        parents=True,
        exist_ok=True
    )

    target.write_text(
        json.dumps(
            evidence,
            indent=2
        )
    )

    return target
