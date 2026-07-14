from __future__ import annotations

from runtime.services.base import Service
from runtime.services.container import ContainerdService, NerdctlService
from runtime.services.core import (
    ConfigurationService,
    FilesystemService,
    NetworkingService,
    SecretsService,
    StorageService,
    VerificationService,
)
from runtime.services.lima import WonderlandBuilderService, WonderlandRootlessService
from runtime.services.platform import (
    ApplicationsService,
    ChaosService,
    ControllerService,
    GrafanaService,
    MatrixService,
    ObservabilityService,
    RegistryService,
)


def discover_services(*, full: bool = False) -> list[Service]:
    services: list[Service] = [
        ConfigurationService(),
        FilesystemService(),
        StorageService(),
        SecretsService(),
        WonderlandRootlessService(),
        WonderlandBuilderService(),
        ContainerdService(),
        NerdctlService(),
        NetworkingService(),
        RegistryService(),
        ObservabilityService(),
        GrafanaService(),
        ControllerService(),
        ChaosService(),
        MatrixService(),
        ApplicationsService(),
        VerificationService(),
    ]

    if full:
        return services

    return [service for service in services if not service.full_only]
