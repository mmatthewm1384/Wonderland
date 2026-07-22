from wlplatform.recovery.audit.chain import AuditChain
from wlplatform.recovery.audit.entry import AuditEntry


def test_audit_chain(tmp_path):

    ledger = tmp_path / "audit.json"

    chain = AuditChain(
        ledger
    )

    chain.append(
        AuditEntry(
            "tx-001",
            "restore",
            "PASS"
        )
    )

    chain.append(
        AuditEntry(
            "tx-002",
            "verify",
            "PASS"
        )
    )

    assert chain.verify()
