class PrivacyProcessor:
    """
    PRISM privacy processing contract.
    """

    def inspect(self, artifact):
        raise NotImplementedError

    def sanitize(self, artifact):
        raise NotImplementedError
