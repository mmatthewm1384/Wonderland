from ..artifact import PrismArtifact


class PrismXArtifact(PrismArtifact):
    """
    Secure encrypted media artifact.
    """

    artifact_type = "prismx"

    media_protected = True

    def describe(self):
        data = super().describe()
        data.update({
            "media": True,
            "media_protected": self.media_protected
        })
        return data
