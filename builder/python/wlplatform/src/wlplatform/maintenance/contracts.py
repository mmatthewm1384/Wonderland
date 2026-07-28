from abc import ABC, abstractmethod

from .models import MaintenanceStatus


class MaintenanceProvider(ABC):

    id: str

    @abstractmethod
    def status(self) -> MaintenanceStatus:
        raise NotImplementedError
