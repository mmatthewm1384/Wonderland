from wlplatform.recovery.governance.approval import (
    ApprovalRequest
)

from wlplatform.recovery.governance.bridge import (
    GovernanceBridge
)


def test_governance_approval():

    request = ApprovalRequest(
        transaction_id="tx-001",
        operation="replace",
        target="registry.json",
        risk="high"
    )

    result = GovernanceBridge().approve(
        request,
        "operator",
        "validated recovery"
    )

    evidence = result.evidence()

    assert result.decision == "APPROVED"
    assert "hash" in evidence
