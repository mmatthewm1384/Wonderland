from collections.abc import Mapping
from dataclasses import dataclass
from datetime import datetime
from typing import Any
from uuid import uuid4

from authorization_authority import AuthorizationAuthority
from XCAVIER_CONTAINMENT import (
    AUTHORIZATION_REQUIRED_TRANSITIONS,
    validate_action,
    validate_transition,
)


@dataclass(frozen=True)
class Decision:
    decision_id: str
    outcome: str
    code: str
    reason: str
    authorization_id: str | None = None
    authorization_revision: str | int | None = None


def _decision(
    outcome: str,
    code: str,
    reason: str,
    authorization_id: str | None = None,
    authorization_revision: str | int | None = None,
) -> Decision:
    return Decision(
        decision_id=str(uuid4()),
        outcome=outcome,
        code=code,
        reason=reason,
        authorization_id=authorization_id,
        authorization_revision=authorization_revision,
    )


def _validate_current_authorization(
    record: Mapping[str, Any],
    authorization_id: str | None,
    authority: AuthorizationAuthority | None,
    now: datetime | None,
):
    if authority is None:
        return (
            None,
            None,
            "AUTHORITY_UNAVAILABLE",
            ("Authoritative authorization provider is required."),
        )

    if not isinstance(authorization_id, str) or not authorization_id.strip():
        return None, None, "AUTHORIZATION_ID_MISSING", ("Authorization identity is required.")

    if record.get("authorization_id") != authorization_id:
        return (
            None,
            None,
            "AUTHORIZATION_ID_MISMATCH",
            ("Action record authorization identity does not match."),
        )

    snapshot = authority.get_current_authorization(authorization_id)

    if snapshot is None:
        return (
            None,
            None,
            "AUTHORIZATION_NOT_FOUND",
            ("Authorization was not found in the authoritative ledger."),
        )

    if not isinstance(snapshot.authorization, Mapping):
        return (
            None,
            None,
            "AUTHORIZATION_RECORD_INVALID",
            ("Authoritative authorization record is invalid."),
        )

    # Ignore any authorization supplied by the caller.
    bound_record = dict(record)
    bound_record["authorization"] = dict(snapshot.authorization)

    result = validate_action(bound_record, now=now)

    if not result.valid or result.code != "PASS":
        return (
            None,
            snapshot.revision,
            result.code,
            result.reason,
        )

    return (
        snapshot,
        snapshot.revision,
        "PASS",
        result.reason,
    )


def decide(
    record: Mapping[str, Any],
    now: datetime | None = None,
    *,
    authority: AuthorizationAuthority | None = None,
) -> Decision:
    """
    Decide whether an action has current authorization.

    Caller-supplied authorization data is never authoritative.
    A fresh lookup from the configured authority is mandatory.
    """

    try:
        if not isinstance(record, Mapping):
            return _decision(
                "REJECT",
                "RECORD_INVALID",
                "Action record must be a mapping.",
            )

        authorization_id = record.get("authorization_id")

        snapshot, revision, code, reason = _validate_current_authorization(
            record,
            authorization_id,
            authority,
            now,
        )

        if snapshot is None:
            return _decision(
                "REJECT",
                code,
                reason,
                authorization_id if isinstance(authorization_id, str) else None,
                revision,
            )

        return _decision(
            "ACCEPT",
            "PASS",
            reason,
            authorization_id,
            revision,
        )

    except Exception:
        return _decision(
            "REJECT",
            "AUTHORIZATION_VALIDATION_ERROR",
            "Authorization validation failed safely.",
        )


def decide_transition(
    current_state: str,
    target_state: str,
    expected_version: int,
    current_version: int,
    *,
    action_record: Mapping[str, Any] | None = None,
    authorization_id: str | None = None,
    authority: AuthorizationAuthority | None = None,
    now: datetime | None = None,
) -> Decision:

    try:
        transition = validate_transition(
            current_state,
            target_state,
            expected_version,
            current_version,
        )

        if not transition.valid or transition.code != "PASS":
            return _decision(
                "REJECT",
                transition.code,
                transition.reason,
            )

        edge = (current_state, target_state)

        if edge not in AUTHORIZATION_REQUIRED_TRANSITIONS:
            return _decision(
                "ACCEPT",
                "PASS",
                transition.reason,
            )

        if not isinstance(action_record, Mapping):
            return _decision(
                "REJECT",
                "ACTION_RECORD_INVALID",
                "A bound action record is required.",
                authorization_id,
            )

        snapshot, revision, code, reason = _validate_current_authorization(
            action_record,
            authorization_id,
            authority,
            now,
        )

        if snapshot is None:
            return _decision(
                "REJECT",
                code,
                reason,
                authorization_id,
                revision,
            )

        return _decision(
            "ACCEPT",
            "PASS",
            "Transition and current authorization are valid.",
            authorization_id,
            revision,
        )

    except Exception:
        return _decision(
            "REJECT",
            "TRANSITION_VALIDATION_ERROR",
            "Transition validation failed safely.",
            authorization_id,
        )
