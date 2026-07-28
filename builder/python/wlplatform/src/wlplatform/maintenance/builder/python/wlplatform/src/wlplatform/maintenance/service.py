from __future__ import annotations

from .models import *
from .contracts import *


class MaintenanceService:
    """
    Wonderland maintenance orchestration service.

    Coordinates maintenance operations while delegating
    implementation to adapters and platform services.
    """

    def doctor(self):
        raise NotImplementedError

    def repair(self):
        raise NotImplementedError

    def verify(self):
        raise NotImplementedError

    def status(self):
        raise NotImplementedError
