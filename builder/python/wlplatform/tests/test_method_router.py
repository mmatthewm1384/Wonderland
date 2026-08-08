import copy

import pytest

from wlplatform.oblivion.execution_intent import (
    ExecutionIntent,
)

from wlplatform.oblivion.method_router import (
    MethodRouter,
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


def test_identity_read_routes():

    result = MethodRouter().route(
        execution_intent()
    )

    assert result["type"] == (
        "oblivion-method-route"
    )

    assert result["schema_version"] == 1

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

    assert result["method"]["provider"] == (
        "registry"
    )

    assert result["method"]["strategy"] == (
        "registry-backed"
    )

    assert result["execution"]["status"] == (
        "PENDING"
    )


def test_route_validates():

    result = MethodRouter().route(
        execution_intent()
    )

    validated = MethodRouter.validate_route(
        result
    )

    assert validated == result


def test_unknown_capability_fails():

    attestation = authorized_attestation()

    attestation["subject"]["capability"] = (
        "unknown.capability"
    )

    intent = ExecutionIntent.create(
        attestation
    )

    with pytest.raises(RuntimeError) as exc:

        MethodRouter().route(
            intent
        )

    assert "No method registered" in str(
        exc.value
    )


def test_unauthorized_intent_cannot_route():

    intent = execution_intent()

    intent["authorization"]["status"] = (
        "DENIED"
    )

    with pytest.raises(RuntimeError):

        MethodRouter().route(
            intent
        )


def test_route_is_defensive_copy():

    intent = execution_intent()

    result = MethodRouter().route(
        intent
    )

    original = copy.deepcopy(
        result
    )

    result["method"]["id"] = (
        "modified"
    )

    assert original["method"]["id"] == (
        "identity.registry"
    )


def test_invalid_method_is_rejected():

    methods = {
        "identity.read": [
            {
                "id": "",
                "provider": "registry",
                "strategy": "registry-backed",
            }
        ]
    }

    with pytest.raises(RuntimeError):

        MethodRouter(
            methods=methods
        ).route(
            execution_intent()
        )
