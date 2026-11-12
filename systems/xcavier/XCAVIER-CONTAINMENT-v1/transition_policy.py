from dataclasses import dataclass

TRANSITIONS = {
    "DRAFT": {"PROPOSED"},
    "PROPOSED": {"VALIDATED", "REJECTED", "CANCELLED"},
    "VALIDATED": {"AUTHORIZED", "REJECTED", "CANCELLED"},
    "AUTHORIZED": {
        "ACCEPTED",
        "REVOKED",
        "EXPIRED",
        "CANCELLED",
    },
    "ACCEPTED": {
        "IN_PROGRESS",
        "REVOKED",
        "EXPIRED",
        "CANCELLED",
    },
    "IN_PROGRESS": {
        "COMPLETED",
        "FAILED",
        "CANCELLED",
        "REVOKED",
        "EXPIRED",
    },
    "COMPLETED": set(),
    "REJECTED": set(),
    "REVOKED": set(),
    "EXPIRED": set(),
    "CANCELLED": set(),
    "FAILED": set(),
}


AUTHORIZATION_REQUIRED_TRANSITIONS = frozenset(
    {
        ("VALIDATED", "AUTHORIZED"),
        ("AUTHORIZED", "ACCEPTED"),
        ("ACCEPTED", "IN_PROGRESS"),
        ("IN_PROGRESS", "COMPLETED"),
    }
)


@dataclass(frozen=True)
class TransitionResult:
    valid: bool
    code: str
    reason: str


def validate_transition(
    current_state: str,
    target_state: str,
    expected_version: int,
    current_version: int,
) -> TransitionResult:

    if not isinstance(current_state, str) or current_state not in TRANSITIONS:
        return TransitionResult(
            False,
            "UNKNOWN_CURRENT_STATE",
            "Current state is not recognized.",
        )

    if not isinstance(target_state, str) or target_state not in TRANSITIONS:
        return TransitionResult(
            False,
            "UNKNOWN_TARGET_STATE",
            "Target state is not recognized.",
        )

    for value in (expected_version, current_version):
        if not isinstance(value, int) or isinstance(value, bool) or value < 0:
            return TransitionResult(
                False,
                "STATE_VERSION_INVALID",
                "State versions must be non-negative integers.",
            )

    if expected_version != current_version:
        return TransitionResult(
            False,
            "STATE_VERSION_CONFLICT",
            "State changed since the operation was read.",
        )

    if target_state not in TRANSITIONS[current_state]:
        return TransitionResult(
            False,
            "TRANSITION_NOT_PERMITTED",
            f"{current_state} cannot transition to {target_state}.",
        )

    return TransitionResult(
        True,
        "PASS",
        "Transition is permitted.",
    )
