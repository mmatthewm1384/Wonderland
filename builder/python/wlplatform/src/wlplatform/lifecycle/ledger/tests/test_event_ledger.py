from pathlib import Path

from wlplatform.lifecycle.ledger.writer import (
    LifecycleLedger
)

from wlplatform.lifecycle.ledger.service import (
    LifecycleEventService
)


def test_event_recording(tmp_path):

    ledger = LifecycleLedger(
        tmp_path / "events.json"
    )

    service = LifecycleEventService(
        ledger
    )

    service.transition(
        "READY",
        "RUNNING",
        "runtime"
    )

    events = ledger.read()

    assert len(events) == 1

    assert events[0]["result"] == "PASS"
