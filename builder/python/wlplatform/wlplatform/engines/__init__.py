from ..engine_contract import EngineContract

from .registry import RegistryEngine


class ArchitectureEngine(EngineContract):
    name = "architecture"


class BuilderEngine(EngineContract):
    name = "builder"


class GovernanceEngine(EngineContract):
    name = "governance"


class MirrorEngine(EngineContract):
    name = "mirror"


class AcademyEngine(EngineContract):
    name = "academy"



_ENGINE_MAP = {
    "architecture": ArchitectureEngine,
    "builder": BuilderEngine,
    "governance": GovernanceEngine,
    "mirror": MirrorEngine,
    "academy": AcademyEngine,
    "registry": RegistryEngine,
}


def get_engine(name, root):

    engine_class = _ENGINE_MAP.get(name)

    if engine_class is None:
        raise ValueError(
            f"Unknown engine: {name}"
        )

    return engine_class(root)


__all__ = [
    "ArchitectureEngine",
    "BuilderEngine",
    "GovernanceEngine",
    "MirrorEngine",
    "AcademyEngine",
    "RegistryEngine",
    "get_engine",
]
