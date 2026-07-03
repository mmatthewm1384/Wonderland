from __future__ import annotations

from wlbuilder.stages.base import BuilderStage
from wlbuilder.stages.disk import DiskStage
from wlbuilder.stages.mount import MountStage
from wlbuilder.stages.bootstrap import BootstrapStage
from wlbuilder.stages.packages import PackagesStage
from wlbuilder.stages.identity import IdentityStage
from wlbuilder.stages.locale import LocaleStage
from wlbuilder.stages.users import UsersStage
from wlbuilder.stages.networking import NetworkingStage
from wlbuilder.stages.bootloader import BootloaderStage
from wlbuilder.stages.verify_image import VerifyImageStage
from wlbuilder.stages.cleanup import CleanupStage
from wlbuilder.stages.convert import ConvertStage
from wlbuilder.stages.manifest import ManifestStage

def default_pipeline() -> list[BuilderStage]:
    return [
        DiskStage(),
        MountStage(),
        BootstrapStage(),
        PackagesStage(),
        IdentityStage(),
        LocaleStage(),
        UsersStage(),
        NetworkingStage(),
        BootloaderStage(),
        VerifyImageStage(),
        CleanupStage(),
        ConvertStage(),
        ManifestStage(),
    ]
