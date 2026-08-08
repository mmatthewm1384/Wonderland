import pytest

from wlplatform.oblivion.execution_intent import (
    ExecutionIntent,
)
from wlplatform.oblivion.executor import (
    ExecutionExecutor,
    ExecutionExecutorError,
)
from wlplatform.oblivion.method_router import (
    MethodRouter,
)
from wlplatform.oblivion.provider import (
    ProviderExecutor,
    ProviderResult,
)


def authorized_attestation():
    return {
        "type": "capability-attestation",
        "schema_version": 2,
        "generated": "2026-08-08T12:38:01+00:00",
        "subject": {
            "package": "trust-foundation-v1",
            "capability": "identity.read",
        },
        "decision": {
            "status": "GRANTED",
            "reason": "Capability authorized",
        },
        "authority": {
            "registry_index_sha256":
                "sha256:e077a5894f7da9a1c21eee7c9d0dd8fae95f68741ccc1dbeb7f66946dfa93997"
        },
    }


def execution_route():
    intent = ExecutionIntent.create(
        authorized_attestation()
    )

    return MethodRouter().route(
        intent
    )


class SuccessProvider:
    def execute(self, context):
        return ProviderResult(
            provider="registry",
            method=context.method["id"],
            data={
                "identity": "resolved",
            },
        )


class FailingProvider:
    def execute(self, context):
        raise RuntimeError(
            "provider unavailable"
        )


def executor_with(provider):
    return ExecutionExecutor(
        ProviderExecutor(
            {
                "registry": provider,
            }
        )
    )


def test_successful_execution_completes_transaction():
    result = executor_with(
        SuccessProvider()
    ).execute(
        execution_route()
    )

    assert result["type"] == (
        "oblivion-execution-transaction"
    )

    assert result["state"] == {
        "status": "SUCCEEDED"
    }

    assert result["result"] == {
        "provider": "registry",
        "method": "identity.registry",
        "data": {
            "identity": "resolved",
        },
    }

    assert result["error"] is None


def test_provider_failure_marks_transaction_failed():
    executor = executor_with(
        FailingProvider()
    )

    with pytest.raises(
        RuntimeError,
        match="provider unavailable",
    ):
        executor.execute(
            execution_route()
        )


def test_provider_failure_is_not_silently_converted():
    executor = executor_with(
        FailingProvider()
    )

    try:
        executor.execute(
            execution_route()
        )
    except RuntimeError as exc:
        assert str(exc) == (
            "provider unavailable"
        )
    else:
        raise AssertionError(
            "provider failure was swallowed"
        )


def test_unauthorized_route_is_rejected():
    route = execution_route()

    route["authorization"]["status"] = (
        "DENIED"
    )

    with pytest.raises(
        ExecutionExecutorError
    ):
        executor_with(
            SuccessProvider()
        ).execute(route)


def test_invalid_route_is_rejected():
    with pytest.raises(
        ExecutionExecutorError
    ):
        executor_with(
            SuccessProvider()
        ).execute({})


def test_execution_does_not_mutate_route():
    route = execution_route()

    original = {
        "type": route["type"],
        "schema_version": route[
            "schema_version"
        ],
        "subject": dict(
            route["subject"]
        ),
        "authorization": dict(
            route["authorization"]
        ),
        "method": dict(
            route["method"]
        ),
        "execution": dict(
            route["execution"]
        ),
    }

    executor_with(
        SuccessProvider()
    ).execute(route)

    assert route["type"] == original["type"]
    assert route["schema_version"] == (
        original["schema_version"]
    )
    assert route["subject"] == (
        original["subject"]
    )
    assert route["authorization"] == (
        original["authorization"]
    )
    assert route["method"] == (
        original["method"]
    )
    assert route["execution"] == (
        original["execution"]
    )


def test_executor_requires_provider_executor():
    with pytest.raises(
        ExecutionExecutorError
    ):
        ExecutionExecutor(None)


def test_provider_result_becomes_transaction_result():
    result = executor_with(
        SuccessProvider()
    ).execute(
        execution_route()
    )

    assert result["result"]["provider"] == (
        "registry"
    )

    assert result["result"]["method"] == (
        "identity.registry"
    )

    assert result["result"]["data"][
        "identity"
    ] == "resolved"
