from __future__ import annotations

from .engine_contract import EngineResult
from .result import CheckResult


def normalize_engine_result(
    result,
    *,
    engine: str,
    action: str = "verify",
):
    """
    Convert legacy CheckResult objects
    into the canonical EngineResult contract.
    """

    if isinstance(result, EngineResult):
        return result


    if isinstance(result, CheckResult):

        return EngineResult(
            engine=engine,
            action=action,
            status=result.status.value,
            details={
                "summary": result.summary,
                "duration_ms": result.duration_ms,
            },
        )


    if isinstance(result, dict):

        return EngineResult(
            engine=engine,
            action=action,
            status=result.get(
                "status",
                "UNKNOWN",
            ),
            details=result,
        )


    raise TypeError(
        f"Unsupported engine result: {type(result)!r}"
    )
