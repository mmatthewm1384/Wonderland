from .model import (
    RecoveryRequest,
    PolicyDecision
)


PROTECTED_TARGETS = [
    "vault/05-Registry",
    "builder/python/wlplatform",
]


HIGH_RISK_OPERATIONS = [
    "replace",
    "delete",
    "reset",
]


def evaluate(request: RecoveryRequest):

    for protected in PROTECTED_TARGETS:

        if protected in request.target:

            return PolicyDecision(
                decision="REQUIRE_APPROVAL",
                reason="Protected target"
            )


    if request.operation in HIGH_RISK_OPERATIONS:

        if request.emergency:

            return PolicyDecision(
                decision="ALLOW",
                reason="Emergency recovery"
            )

        return PolicyDecision(
            decision="REQUIRE_APPROVAL",
            reason="High risk operation"
        )


    return PolicyDecision(
        decision="ALLOW",
        reason="Standard recovery"
    )
