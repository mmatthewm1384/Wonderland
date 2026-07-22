from wlplatform.lifecycle.drift.engine import (
    DriftDetectionEngine
)

from wlplatform.lifecycle.drift.analyzer import (
    DriftAnalyzer
)



def test_detect_drift():

    engine = DriftDetectionEngine(
        DriftAnalyzer()
    )


    result = engine.detect(
        "runtime",
        "RUNNING",
        "STOPPED"
    )


    assert result.drift is True

    assert result.severity == "HIGH"



def test_no_drift():

    engine = DriftDetectionEngine(
        DriftAnalyzer()
    )


    result = engine.detect(
        "runtime",
        "RUNNING",
        "RUNNING"
    )


    assert result.drift is False
