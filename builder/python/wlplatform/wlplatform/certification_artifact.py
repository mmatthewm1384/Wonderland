from __future__ import annotations


REQUIRED_FIELDS = (
    "engine",
    "action",
    "status",
)


VALID_STATUSES = (
    "PASS",
    "FAIL",
    "WARN",
    "UNKNOWN",
)


class CertificationArtifactError(
    RuntimeError
):
    pass


def validate_artifact(
    artifact: dict,
):
    """
    Validate persisted certification evidence.
    """

    errors = []

    for field in REQUIRED_FIELDS:
        if field not in artifact:
            errors.append(
                f"missing field: {field}"
            )

    status = artifact.get(
        "status"
    )

    if status not in VALID_STATUSES:
        errors.append(
            f"invalid status: {status}"
        )

    if (
        artifact.get("certified")
        is True
        and status != "PASS"
    ):
        errors.append(
            "certified requires PASS"
        )

    return {
        "valid": not errors,
        "errors": errors,
    }
