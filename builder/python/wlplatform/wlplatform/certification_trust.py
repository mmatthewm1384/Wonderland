"""
Wonderland Certification Trust Evaluator

Evaluates certification graph state.

This module explains trust state.
It does not certify engines.
"""

from pathlib import Path
from datetime import datetime, timezone
import json


TRUST_SCHEMA_VERSION = 1


DEFAULT_REQUIRED_ENGINES = {
    "runtime",
    "repository",
    "builder",
    "academy",
    "security",
    "architecture",
}


class CertificationTrustEvaluator:

    def __init__(self, root):

        self.root = Path(root)

        self.graph_path = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "graph"
            / "certification-graph.json"
        )

        self.output_path = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "graph"
            / "trust-state.json"
        )


    def load_graph(self):

        if not self.graph_path.exists():
            return None

        return json.loads(
            self.graph_path.read_text()
        )


    def evaluate(self):

        graph = self.load_graph()

        if graph is None:
            raise RuntimeError(
                "Certification graph missing"
            )

        nodes = graph.get(
            "nodes",
            {}
        )

        certified = {
            name
            for name, node in nodes.items()
            if node.get("certified") is True
        }

        missing = sorted(
            DEFAULT_REQUIRED_ENGINES
            - certified
        )

        state = {
            "schema_version": TRUST_SCHEMA_VERSION,
            "generated": datetime.now(
                timezone.utc
            ).isoformat(),
            "trust": (
                "CERTIFIED"
                if not missing
                else "INCOMPLETE"
            ),
            "certified": (
                len(missing) == 0
            ),
            "checks": {
                "evidence_present": bool(nodes),
                "digests_present": all(
                    node.get("digest")
                    for node in nodes.values()
                ),
                "required_engines_complete": (
                    len(missing) == 0
                ),
            },
            "missing": missing,
        }

        self.output_path.write_text(
            json.dumps(
                state,
                indent=2,
            )
            + "\n"
        )

        return state
