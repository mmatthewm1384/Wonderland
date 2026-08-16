from wlplatform.paths import repository_root

from wlplatform.paths import repository_root

from wlplatform.engines import get_engine
from wlplatform.certification_registry import (
    CertificationRegistry,
)


ROOT = repository_root()


def test_engine_artifact_alignment():

    registry = CertificationRegistry(
        ROOT
    )

    active = registry.normalize_active()

    failures = []

    for name in (
        "architecture",
        "registry",
        "mirror",
    ):

        engine = get_engine(
            name,
            ROOT,
        )

        result = engine.verify()

        live_status = (
            result.status.value
            if hasattr(result.status, "value")
            else result.status
        )

        artifact = active.get(
            name,
            {},
        )

        if artifact.get(
            "status"
        ) != live_status:

            failures.append(
                f"{name}: "
                f"live={live_status} "
                f"artifact={artifact.get('status')}"
            )

    assert not failures, failures
