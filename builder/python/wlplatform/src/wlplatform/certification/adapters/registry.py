from pathlib import Path

from .base import EngineAdapter
from ...paths import repository_root


class ArtifactAdapter(EngineAdapter):

    def __init__(self, name, root=None):
        self.name = name
        self.root = (
            Path(root).resolve()
            if root is not None
            else repository_root()
        )

    def verify(self):
        return self.certify()

    def certify(self):
        from ..contract import CertificationResult

        root = self.root

        artifact = (
            root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "normalized"
            / f"{self.name}.json"
        )

        if not artifact.exists():
            return CertificationResult(
                engine=self.name,
                status="FAIL",
                evidence=[
                    {
                        "missing": str(artifact)
                    }
                ],
                details={
                    "adapter": "artifact-validation"
                }
            )

        import json

        data = json.loads(
            artifact.read_text()
        )

        status = data.get(
            "status",
            "FAIL"
        )

        certified = data.get(
            "certified",
            False
        )

        return CertificationResult(
            engine=self.name,
            status=status if certified else "FAIL",
            evidence=[
                {
                    "artifact": str(artifact),
                    "digest": data.get("digest")
                }
            ],
            details={
                "adapter": "artifact-validation"
            }
        )


def configure_adapters(root):
    for adapter in ADAPTERS:
        adapter.set_root(root)


ADAPTERS = [
    ArtifactAdapter("architecture"),
    ArtifactAdapter("builder"),
    ArtifactAdapter("governance"),
    ArtifactAdapter("mirror"),
    ArtifactAdapter("academy"),
    ArtifactAdapter("registry"),
    ArtifactAdapter("repository"),
    ArtifactAdapter("runtime"),
]


def adapters(root=None):
    return [
        ArtifactAdapter(
            adapter.name,
            root=root,
        )
        for adapter in ADAPTERS
    ]
