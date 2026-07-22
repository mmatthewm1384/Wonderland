class EncryptionProvider:
    """
    PRISM encryption provider contract.
    """

    def encrypt(self, artifact):
        raise NotImplementedError

    def decrypt(self, artifact):
        raise NotImplementedError
