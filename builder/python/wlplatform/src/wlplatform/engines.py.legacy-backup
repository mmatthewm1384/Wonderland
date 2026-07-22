from __future__ import annotations

from .engine_contract import EngineContract, EngineResult


class ArchitectureEngine(EngineContract):

    name = "architecture"

    def verify(self):

        graph = (
            self.root
            /
            "vault/08-Operations/certifications/graph/certification-graph.json"
        )

        exists = graph.exists()

        return EngineResult(
            engine=self.name,
            action="verify",
            status=(
                "PASS"
                if exists
                else "FAIL"
            ),
            details={
                "graph": str(graph),
                "exists": exists,
            },
        )


    def certify(self):

        result = self.verify()

        if result.status != "PASS":
            return result

        path = self.write_artifact(result)

        return EngineResult(
            engine=self.name,
            action="certify",
            status="PASS",
            details={
                "artifact": str(path),
            },
        )


class BuilderEngine(EngineContract):
    name = "builder"


class GovernanceEngine(EngineContract):
    name = "governance"


class MirrorEngine(EngineContract):
    name = "mirror"


class AcademyEngine(EngineContract):
    name = "academy"


# RegistryEngine moved to:
# wlplatform.engines.registry.RegistryEngine
#
# Kept here as compatibility marker only.



# Engine factory compatibility layer
#
# Public import contract:
#   from wlplatform.engines import get_engine
#
# RegistryEngine ownership:
#   wlplatform.engines.registry.RegistryEngine





_ENGINE_MAP = {
    "architecture": ArchitectureEngine,
    "builder": BuilderEngine,
    "governance": GovernanceEngine,
    "mirror": MirrorEngine,
    "academy": AcademyEngine,
    "registry": RegistryEngine,
}


def get_engine(name: str, root):

    engine = _ENGINE_MAP.get(name)

    if engine is None:
        raise ValueError(
            f"Unknown engine: {name}"
        )

    return engine(root)





class RegistryEngine(EngineContract):

    name = "registry"

    def verify(self):

        registry = (
            self.root
            /
            "vault/05-Registry"
        )

        exists = registry.exists()

        return EngineResult(
            engine=self.name,
            action="verify",
            status=(
                "PASS"
                if exists
                else "FAIL"
            ),
            details={
                "registry_root": str(registry),
                "exists": exists,
            },
        )



from .engines.registry import RegistryEngine


def get_engine(name, root):

    engines = {
        "architecture": ArchitectureEngine,
        "builder": BuilderEngine,
        "governance": GovernanceEngine,
        "mirror": MirrorEngine,
        "academy": AcademyEngine,
        "registry": RegistryEngine,
    }

    engine = engines.get(name)

    if engine is None:
        raise ValueError(
            f"Unknown engine: {name}"
        )

    return engine(root)
