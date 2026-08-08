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

import pytest

from wlplatform.oblivion.execution_transaction import (
    ExecutionTransaction,
)


def execution_intent():
    return {
        "type": "execution-intent",
        "schema_version": 1,
        "subject": {
            "package": "trust-foundation-v1",
            "capability": "identity.read",
        },
    }


def test_initial_state():
    transaction = ExecutionTransaction(
        execution_intent(),
        method="identity.read",
    )

    assert transaction.state == "PENDING"


def test_prepare():
    transaction = ExecutionTransaction(
        execution_intent(),
        method="identity.read",
    )

    result = transaction.prepare()

    assert result["state"] == "READY"


def test_start():
    transaction = ExecutionTransaction(
        execution_intent(),
        method="identity.read",
    )

    transaction.prepare()
    result = transaction.start()

    assert result["state"] == "RUNNING"
    assert transaction.started is not None


def test_complete():
    transaction = ExecutionTransaction(
        execution_intent(),
        method="identity.read",
    )

    transaction.prepare()
    transaction.start()

    result = transaction.complete(
        {"identity": "resolved"}
    )

    assert result["state"] == "SUCCEEDED"
    assert result["result"] == {
        "identity": "resolved"
    }


def test_fail():
    transaction = ExecutionTransaction(
        execution_intent(),
        method="identity.read",
    )

    transaction.prepare()
    transaction.start()

    result = transaction.fail(
        "provider unavailable"
    )

    assert result["state"] == "FAILED"
    assert result["error"] == "provider unavailable"


def test_rollback():
    transaction = ExecutionTransaction(
        execution_intent(),
        method="identity.read",
    )

    transaction.prepare()
    transaction.start()
    transaction.fail("provider unavailable")

    result = transaction.rollback()

    assert result["state"] == "ROLLED_BACK"
    assert transaction.rolled_back is not None


@pytest.mark.parametrize(
    "operation",
    [
        "start",
        "complete",
        "fail",
        "rollback",
    ],
)
def test_illegal_initial_transition(operation):
    transaction = ExecutionTransaction(
        execution_intent(),
        method="identity.read",
    )

    with pytest.raises(RuntimeError):
        getattr(transaction, operation)()


def test_missing_method_rejected():
    transaction = ExecutionTransaction(
        execution_intent(),
        method=None,
    )

    with pytest.raises(RuntimeError):
        transaction.prepare()


def test_intent_is_preserved():
    intent = execution_intent()

    transaction = ExecutionTransaction(
        intent,
        method="identity.read",
    )

    transaction.prepare()

    assert transaction.intent is intent
    assert (
        transaction.snapshot()["intent"]
        == intent
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


def route():
    intent = ExecutionIntent.create(
        authorized_attestation()
    )

    return MethodRouter().route(
        intent
    )


def test_transaction_created_pending():

    result = ExecutionTransaction.create(
        route()
    )

    assert result["type"] == (
        "oblivion-execution-transaction"
    )

    assert result["schema_version"] == 1

    assert result["transaction_id"].startswith(
        "txn-"
    )

    assert result["subject"]["package"] == (
        "trust-foundation-v1"
    )

    assert result["subject"]["capability"] == (
        "identity.read"
    )

    assert result["authorization"]["status"] == (
        "GRANTED"
    )

    assert result["method"]["id"] == (
        "identity.registry"
    )

    assert result["state"]["status"] == (
        "PENDING"
    )

    assert result["result"] is None
    assert result["error"] is None


def test_transaction_validates():

    transaction = ExecutionTransaction.create(
        route()
    )

    validated = ExecutionTransaction.validate(
        transaction
    )

    assert validated == transaction


def test_transaction_state_machine():

    transaction = ExecutionTransaction.create(
        route()
    )

    transaction = ExecutionTransaction.transition(
        transaction,
        "PREPARED",
    )

    assert transaction["state"]["status"] == (
        "PREPARED"
    )

    transaction = ExecutionTransaction.transition(
        transaction,
        "RUNNING",
    )

    assert transaction["state"]["status"] == (
        "RUNNING"
    )

    transaction = ExecutionTransaction.succeed(
        transaction,
        {
            "value": "test",
        },
    )

    assert transaction["state"]["status"] == (
        "SUCCEEDED"
    )

    assert transaction["result"]["value"] == (
        "test"
    )


def test_failed_transaction_can_rollback():

    transaction = ExecutionTransaction.create(
        route()
    )

    transaction = ExecutionTransaction.fail(
        transaction,
        "provider unavailable",
    )

    assert transaction["state"]["status"] == (
        "FAILED"
    )

    assert transaction["error"]["reason"] == (
        "provider unavailable"
    )

    transaction = ExecutionTransaction.rollback(
        transaction
    )

    assert transaction["state"]["status"] == (
        "ROLLED_BACK"
    )


def test_illegal_transition_rejected():

    transaction = ExecutionTransaction.create(
        route()
    )

    with pytest.raises(RuntimeError):

        ExecutionTransaction.transition(
            transaction,
            "SUCCEEDED",
        )


def test_terminal_transaction_cannot_continue():

    transaction = ExecutionTransaction.create(
        route()
    )

    transaction = ExecutionTransaction.transition(
        transaction,
        "PREPARED",
    )

    transaction = ExecutionTransaction.transition(
        transaction,
        "RUNNING",
    )

    transaction = ExecutionTransaction.succeed(
        transaction
    )

    with pytest.raises(RuntimeError):

        ExecutionTransaction.transition(
            transaction,
            "FAILED",
        )


def test_unauthorized_route_cannot_create_transaction():

    route_data = route()

    route_data["authorization"]["status"] = (
        "DENIED"
    )

    with pytest.raises(RuntimeError):

        ExecutionTransaction.create(
            route_data
        )


def test_result_cannot_exist_in_active_state():

    transaction = ExecutionTransaction.create(
        route()
    )

    transaction["result"] = {
        "unexpected": True,
    }

    with pytest.raises(RuntimeError):

        ExecutionTransaction.validate(
            transaction
        )
