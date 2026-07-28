from __future__ import annotations

from abc import ABC, abstractmethod

from .models import MaintenanceStatus


class MaintenanceProvider(ABC):
    """
    Contract every maintenance provider must implement.
    """

    id: str


    @abstractmethod
    def detect(self) -> bool:
        """
        Determine whether provider exists.
        """
        raise NotImplementedError


    @abstractmethod
    def status(self) -> MaintenanceStatus:
        """
        Return provider health information.
        """
        raise NotImplementedError
