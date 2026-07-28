from __future__ import annotations

"""
Wonderland Platform Service Composition Boundary.

Services package exposes orchestration dependencies only.
Capability ownership remains in domain packages.
"""

from wlplatform.platform.service import PlatformService
from wlplatform.runtime.service import RuntimeService
from wlplatform.governance.service import GovernanceService
from wlplatform.registry.service import RegistryService
from wlplatform.telemetry.service import TelemetryService

__all__ = [
    "PlatformService",
    "RuntimeService",
    "GovernanceService",
    "RegistryService",
    "TelemetryService",
]
