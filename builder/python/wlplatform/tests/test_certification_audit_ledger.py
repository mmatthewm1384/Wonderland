"""
Certification Audit Ledger Verification
"""



def test_audit_import():

    from wlplatform.certification.audit import (
        CertificationAuditLedger
    )

    assert CertificationAuditLedger



def test_append_event(tmp_path):

    from wlplatform.certification.audit import (
        CertificationAuditLedger
    )


    ledger = CertificationAuditLedger(
        tmp_path /
        "ledger.jsonl"
    )


    ledger.append(
        "CERTIFICATION_COMPLETED",
        "runtime",
        "certification-policy-v1.1",
        "certification-governance-v1.1",
        "CERTIFIED"
    )


    entries = ledger.entries()


    assert len(entries) == 1



def test_event_contains_lineage(tmp_path):

    from wlplatform.certification.audit import (
        CertificationAuditLedger
    )


    ledger = CertificationAuditLedger(
        tmp_path /
        "ledger.jsonl"
    )


    ledger.append(
        "CERTIFICATION_COMPLETED",
        "runtime",
        "policy",
        "governance",
        "CERTIFIED"
    )


    event = ledger.entries()[0]


    assert event["policy"] == "policy"
    assert event["governance"] == "governance"



def test_verify(tmp_path):

    from wlplatform.certification.audit import (
        CertificationAuditLedger
    )


    ledger = CertificationAuditLedger(
        tmp_path /
        "ledger.jsonl"
    )


    ledger.append(
        "CERTIFICATION_COMPLETED",
        "runtime",
        "policy",
        "governance",
        "CERTIFIED"
    )


    assert ledger.verify()
