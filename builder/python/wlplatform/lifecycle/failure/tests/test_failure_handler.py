from wlplatform.lifecycle.failure.models import (
    LifecycleFailure
)

from wlplatform.lifecycle.failure.handler import (
    LifecycleFailureHandler
)


def test_failure_capture(tmp_path):

    handler = LifecycleFailureHandler(
        tmp_path / "failure.json"
    )

    failure = LifecycleFailure(
        component="runtime",
        state="RUNNING",
        error="health check failed",
        severity="HIGH"
    )


    evidence = handler.handle(
        failure
    )


    assert evidence["component"] == "runtime"
    assert evidence["severity"] == "HIGH"
