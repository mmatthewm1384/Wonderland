from __future__ import annotations

from wl.runtime.services.base import Service, state_dir


class ConfigurationService(Service):
    def __init__(self) -> None:
        super().__init__("configuration", required=True)


class FilesystemService(Service):
    def __init__(self) -> None:
        super().__init__("filesystem", required=True)

    def check(self) -> bool:
        return state_dir().exists()

    def start(self) -> bool:
        state_dir()
        return self.check()


class StorageService(Service):
    def __init__(self) -> None:
        super().__init__("storage", required=True)


class SecretsService(Service):
    def __init__(self) -> None:
        super().__init__("secrets", required=True)


class NetworkingService(Service):
    def __init__(self) -> None:
        super().__init__("networking", required=True)


class VerificationService(Service):
    def __init__(self) -> None:
        super().__init__("verification", required=True)
