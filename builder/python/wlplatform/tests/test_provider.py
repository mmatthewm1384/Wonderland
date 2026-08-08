from copy import deepcopy

import pytest

from wlplatform.oblivion.execution_intent import (
    ExecutionIntent,
)
from wlplatform.oblivion.method_router import (
    MethodRouter,
)
from wlplatform.oblivion.execution_transaction import (
    ExecutionTransaction,
)
from wlplatform.oblivion.provider import (
    ProviderContext,
    ProviderContractError,
    ProviderExecutor,
    ProviderNotFoundError,
    ProviderResult,
    RegistryProvider,
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


def execution_intent():
    return ExecutionIntent.create(
        authorized_attestation()
    )


def running_transaction():
    intent = execution_intent()

    route = MethodRouter().route(
        intent
    )

    transaction = ExecutionTransaction.create(
        route
    )

    transaction = ExecutionTransaction.transition(
        transaction,
        "PREPARED",
    )

    transaction = ExecutionTransaction.transition(
        transaction,
        "RUNNING",
    )

    return transaction


class EchoProvider:
    def execute(
        self,
        context,
    ):
        return {
            "echo": context.subject,
        }


def test_provider_context_is_defensive():
    transaction = running_transaction()

    context = ProviderContext(
        transaction_id=transaction[
            "transaction_id"
        ],
        subject=transaction["subject"],
        authorization=transaction[
            "authorization"
        ],
        method=transaction["method"],
        intent=transaction["intent"],
    )

    snapshot = context.snapshot()

    snapshot["subject"]["package"] = "modified"

    assert (
        context.subject["package"]
        == "trust-foundation-v1"
    )


def test_provider_result_is_defensive():
    result = ProviderResult(
        provider="registry",
        method="identity.registry",
        data={"identity": "resolved"},
    )

    snapshot = result.snapshot()

    snapshot["data"]["identity"] = "modified"

    assert (
        result.data["identity"]
        == "resolved"
    )


def test_provider_executes_running_transaction():
    transaction = running_transaction()

    executor = ProviderExecutor(
        {
            "registry": EchoProvider(),
        }
    )

    result = executor.execute(
        transaction
    )

    assert result["type"] == (
        "oblivion-provider-execution"
    )

    assert result["schema_version"] == 1

    assert result["transaction_id"] == (
        transaction["transaction_id"]
    )

    assert result["provider"] == "registry"

    assert result["method"] == (
        "identity.registry"
    )

    assert result["result"]["echo"][
        "capability"
    ] == "identity.read"


def test_provider_must_exist():
    transaction = running_transaction()

    executor = ProviderExecutor()

    with pytest.raises(
        ProviderNotFoundError
    ):
        executor.execute(
            transaction
        )


def test_provider_requires_running_transaction():
    intent = execution_intent()

    route = MethodRouter().route(
        intent
    )

    transaction = ExecutionTransaction.create(
        route
    )

    executor = ProviderExecutor(
        {"registry": EchoProvider()}
    )

    with pytest.raises(
        ProviderContractError
    ):
        executor.execute(
            transaction
        )


def test_provider_requires_authorization():
    transaction = running_transaction()

    transaction["authorization"][
        "status"
    ] = "DENIED"

    executor = ProviderExecutor(
        {"registry": EchoProvider()}
    )

    with pytest.raises(
        ProviderContractError
    ):
        executor.execute(
            transaction
        )


def test_provider_cannot_return_invalid_result():
    class InvalidProvider:
        def execute(self, context):
            return "invalid"

    transaction = running_transaction()

    executor = ProviderExecutor(
        {"registry": InvalidProvider()}
    )

    with pytest.raises(
        ProviderContractError
    ):
        executor.execute(
            transaction
        )


def test_registry_provider_is_deterministic():
    transaction = running_transaction()

    provider = RegistryProvider(
        {
            "identity.read": {
                "identity": "resolved"
            }
        }
    )

    executor = ProviderExecutor(
        {"registry": provider}
    )

    result = executor.execute(
        transaction
    )

    assert result["result"]["data"]["record"] == {
        "identity": "resolved"
    }


def test_provider_does_not_mutate_transaction():
    transaction = running_transaction()

    original = deepcopy(
        transaction
    )

    executor = ProviderExecutor(
        {"registry": EchoProvider()}
    )

    executor.execute(
        transaction
    )

    assert transaction == original
    assert transaction["state"][
        "status"
    ] == "RUNNING"
