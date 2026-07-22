from wlplatform.recovery.evidence.model import RecoveryEvidence


def test_evidence_hash():

    evidence = RecoveryEvidence(
        transaction_id="test",
        operation="restore",
        source_hash="abc",
        target_hash="def",
        state_before="old",
        state_after="new",
        verification="PASS"
    )

    result = evidence.serialize()

    assert "evidence_hash" in result
