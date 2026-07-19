"""
Certification Evidence Resolver

Discovers certification evidence through
certification-owned artifact boundaries.
"""

from pathlib import Path


class EvidenceResolver:

    def __init__(self, root):

        self.root = Path(root).resolve()


    def certification_root(self):

        return (
            self.root
            /
            "vault"
            /
            "08-Operations"
            /
            "certifications"
        )


    def normalized_root(self):

        return (
            self.certification_root()
            /
            "normalized"
        )


    def resolve_engine_artifact(self, engine):

        artifact = (
            self.normalized_root()
            /
            f"{engine}.json"
        )

        return artifact if artifact.exists() else None


    def resolve_all(self):

        root = self.normalized_root()

        if not root.exists():
            return []

        return sorted(
            [
                path
                for path in root.glob("*.json")
            ]
        )
