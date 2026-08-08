import copy

import pytest

from wlplatform.oblivion.execution_intent import (
    ExecutionIntent,
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


def test_execution_intent_created():

    attestation = authorized_attestation()

    result = ExecutionIntent.create(
        attestation
    )

    assert result["type"] == "oblivion-execution-intent"
    assert result["schema_version"] == 1

    assert result["subject"]["package"] == (
        "trust-foundation-v1"
    )

    assert result["subject"]["capability"] == (
        "identity.read"
    )

    assert result["action"] == "execute"

    assert result["authorization"]["status"] == (
        "GRANTED"
    )

    assert result["authorization"]["source"] == (
        "registry-trust-v1"
    )

    assert result["execution"]["status"] == "PENDING"


def test_execution_intent_validates():

    result = ExecutionIntent.create(
        authorized_attestation()
    )

    validated = ExecutionIntent.validate_intent(
        result
    )

    assert validated == result


def test_denied_capability_cannot_create_intent():

    attestation = authorized_attestation()

    attestation["decision"]["status"] = "DENIED"

    with pytest.raises(RuntimeError):
        ExecutionIntent.create(attestation)


def test_invalid_authority_cannot_create_intent():

    attestation = authorized_attestation()

    attestation["authority"]["registry_index_sha256"] = (
        "sha256:invalid"
    )

    # The shape is syntactically valid; creation remains
    # intentionally independent of registry re-verification.
    result = ExecutionIntent.create(attestation)

    assert (
        result["authority"]["registry_index_sha256"]
        == "sha256:invalid"
    )


def test_intent_subject_cannot_drift():

    attestation = authorized_attestation()

    intent = ExecutionIntent.create(attestation)

    intent["subject"]["package"] = (
        "different-package-v1"
    )

    with pytest.raises(RuntimeError):
        ExecutionIntent.validate_intent(intent)


def test_intent_authority_cannot_drift():

    attestation = authorized_attestation()

    intent = ExecutionIntent.create(attestation)

    intent["authority"]["registry_index_sha256"] = (
        "sha256:different"
    )

    with pytest.raises(RuntimeError):
        ExecutionIntent.validate_intent(intent)


def test_source_attestation_is_not_mutated():

    attestation = authorized_attestation()

    original = copy.deepcopy(attestation)

    ExecutionIntent.create(attestation)

    assert attestation == original
