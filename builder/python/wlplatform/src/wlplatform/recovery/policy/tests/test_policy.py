from wlplatform.recovery.policy.model import RecoveryRequest
from wlplatform.recovery.policy.evaluator import evaluate


def test_protected_target_requires_approval():

    request = RecoveryRequest(
        operation="replace",
        target="vault/05-Registry/platform.json",
        risk="high"
    )

    result = evaluate(request)

    assert result.decision == "REQUIRE_APPROVAL"


def test_standard_recovery_allowed():

    request = RecoveryRequest(
        operation="restore",
        target="tmp/test",
        risk="low"
    )

    result = evaluate(request)

    assert result.decision == "ALLOW"
