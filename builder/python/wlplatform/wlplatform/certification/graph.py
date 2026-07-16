import json
from pathlib import Path
from datetime import datetime, timezone

from .ownership import OWNERSHIP


def build_graph(root):

    graph = {
        "schema_version": 1,
        "generated":
            datetime.now(
                timezone.utc
            ).isoformat(),

        "owners": OWNERSHIP
    }


    path = (
        Path(root)
        /
        "vault/08-Operations/certifications/graph"
    )

    path.mkdir(
        parents=True,
        exist_ok=True
    )

    output = (
        path /
        "certification-graph.json"
    )


    output.write_text(
        json.dumps(
            graph,
            indent=2
        )
    )

    return output
