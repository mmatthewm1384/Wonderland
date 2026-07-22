from pathlib import Path

from wlplatform.engines.architecture import ArchitectureEngine
from wlplatform.engines.registry import RegistryEngine
from wlplatform.engines.mirror import MirrorEngine

from wlplatform.engine_contract import EngineResult


ROOT = Path(".")


def test_engine_verify_contracts():

    engines = (
        ArchitectureEngine(ROOT),
        RegistryEngine(ROOT),
        MirrorEngine(ROOT),
    )

    for engine in engines:

        result = engine.verify()

        assert isinstance(
            result,
            EngineResult,
        ), (
            f"{engine.__class__.__name__} "
            f"returned unsupported type "
            f"{type(result)}"
        )

        assert result.engine == engine.name

        assert result.action == "verify"

        assert result.status in (
            "PASS",
            "FAIL",
            "WARN",
        )
