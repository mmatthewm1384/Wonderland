from wlplatform.paths import repository_root

from wlplatform.engine_contract import EngineResult
from wlplatform.engines import get_engine
from wlplatform.engines.catalog import ENGINE_CATALOG


ROOT = repository_root()

def test_all_registered_engines_return_engine_results():

    failures = []

    for name in ENGINE_CATALOG:

        engine = get_engine(
            name,
            ROOT,
        )

        if not hasattr(engine, "verify"):
            continue

        result = engine.verify()

        if not isinstance(
            result,
            EngineResult,
        ):
            failures.append(
                f"{name}: {type(result).__name__}"
            )

    assert not failures, (
        "engines violating contract: "
        + ", ".join(failures)
    )
