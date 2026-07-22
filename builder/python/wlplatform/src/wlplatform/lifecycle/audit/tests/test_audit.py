from wlplatform.lifecycle.audit.models import (
    AuditEvent
)

from wlplatform.lifecycle.audit.ledger import (
    LifecycleAuditLedger
)



def test_audit_chain():

    ledger = LifecycleAuditLedger()


    first = ledger.append(
        AuditEvent(
            event_type="LIFECYCLE_AUTOMATION",
            action="START",
            status="CERTIFIED",
            correlation_id="001"
        )
    )


    second = ledger.append(
        AuditEvent(
            event_type="LIFECYCLE_AUTOMATION",
            action="VERIFY",
            status="CERTIFIED",
            correlation_id="001"
        )
    )


    assert first["hash"]

    assert (
        second["previous_hash"]
        ==
        first["hash"]
    )
