from __future__ import annotations


def normalize_status(result):
    if hasattr(result, "status"):
        status = result.status

        if hasattr(status, "value"):
            return status.value

        return status

    if isinstance(result, dict):
        return (
            result.get("status")
            or result.get("result")
        )

    return None


def validate_certification_artifact(
    verify_result,
    artifact: dict,
) -> dict:
    """
    Ensure certification artifact matches live verification.
    """

    live_status = normalize_status(
        verify_result
    )

    artifact_status = artifact.get(
        "status"
    )

    certified = artifact.get(
        "certified",
        False,
    )

    errors = []

    if live_status != artifact_status:
        errors.append(
            f"status drift: live={live_status} artifact={artifact_status}"
        )

    if artifact_status == "PASS" and not certified:
        errors.append(
            "PASS artifact missing certified=true"
        )

    if certified and artifact_status != "PASS":
        errors.append(
            "certified artifact not PASS"
        )

    return {
        "valid": not errors,
        "errors": errors,
        "live_status": live_status,
        "artifact_status": artifact_status,
        "certified": certified,
    }
