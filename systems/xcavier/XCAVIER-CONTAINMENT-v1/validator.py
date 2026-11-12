from collections.abc import Mapping
from dataclasses import dataclass
from datetime import UTC, datetime
from typing import Any

ALLOWED_BOUNDARIES = {
    "information",
    "environment",
    "body",
    "cognitive",
}


@dataclass(frozen=True)
class ValidationResult:
    valid: bool
    code: str
    reason: str


def reject(code: str, reason: str) -> ValidationResult:
    return ValidationResult(False, code, reason)


def validate_action(
    record: Mapping[str, Any],
    now: datetime | None = None,
) -> ValidationResult:

    if not isinstance(record, Mapping):
        return reject(
            "RECORD_INVALID",
            "Action record must be a mapping.",
        )

    required = {
        "action_id",
        "subject_id",
        "actor_id",
        "action",
        "purpose",
        "boundary",
        "authorization",
    }

    if not required.issubset(record):
        return reject(
            "REQUIRED_FIELD_MISSING",
            "Required fields are missing.",
        )

    for field in (
        "action_id",
        "subject_id",
        "actor_id",
        "action",
        "purpose",
    ):
        value = record.get(field)

        if not isinstance(value, str) or not value.strip():
            return reject(
                "FIELD_INVALID",
                f"{field} must be a non-empty string.",
            )

    if record["boundary"] not in ALLOWED_BOUNDARIES:
        return reject(
            "BOUNDARY_INVALID",
            "Unrecognized boundary.",
        )

    auth = record["authorization"]

    if not isinstance(auth, Mapping):
        return reject(
            "AUTHORIZATION_MISSING",
            "Structured authorization required.",
        )

    required_auth = {
        "subject_id",
        "actor_id",
        "action",
        "purpose",
        "informed",
        "freely_given",
        "revoked",
        "expires_at",
    }

    if not required_auth.issubset(auth):
        return reject(
            "AUTHORIZATION_INCOMPLETE",
            "Authorization is incomplete.",
        )

    bindings = (
        "subject_id",
        "actor_id",
        "action",
        "purpose",
    )

    for field in bindings:
        if auth[field] != record[field]:
            return reject(
                "AUTHORIZATION_BINDING_MISMATCH",
                f"Authorization mismatch: {field}.",
            )

    if auth["informed"] is not True:
        return reject(
            "CONSENT_NOT_VALID",
            "Informed authorization not established.",
        )

    if auth["freely_given"] is not True:
        return reject(
            "CONSENT_NOT_VALID",
            "Freely given authorization not established.",
        )

    if auth["revoked"] is not False:
        return reject(
            "AUTHORIZATION_REVOKED_OR_UNKNOWN",
            "Authorization revoked or unknown.",
        )

    try:
        expiry = datetime.fromisoformat(auth["expires_at"].replace("Z", "+00:00"))

        if expiry.tzinfo is None:
            raise ValueError("Timezone required.")

    except (ValueError, TypeError, AttributeError):
        return reject(
            "EXPIRY_INVALID",
            "Invalid authorization expiry.",
        )

    now = now or datetime.now(UTC)

    if now.tzinfo is None:
        return reject(
            "CLOCK_INVALID",
            "Timezone-aware clock required.",
        )

    if now >= expiry:
        return reject(
            "AUTHORIZATION_EXPIRED",
            "Authorization has expired.",
        )

    return ValidationResult(
        True,
        "PASS",
        "Containment validation passed.",
    )
