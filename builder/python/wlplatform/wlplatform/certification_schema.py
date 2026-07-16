"""
Wonderland Certification Artifact Schema

Canonical schema definition for engine certification evidence.
"""

ENGINE_SCHEMA_VERSION = 1

REQUIRED_FIELDS = [
    "schema_version",
    "engine",
    "certification",
    "version",
    "status",
    "certified",
    "timestamp",
    "digest",
    "evidence",
]


VALID_STATUSES = {
    "PASS",
    "FAIL",
    "MISSING",
}


def validate_artifact(artifact: dict) -> tuple[bool, list[str]]:
    """
    Validate a certification artifact against
    the Wonderland engine certification schema.
    """

    errors = []

    for field in REQUIRED_FIELDS:
        if field not in artifact:
            errors.append(
                f"missing field: {field}"
            )

    if (
        "schema_version" in artifact
        and artifact["schema_version"]
        != ENGINE_SCHEMA_VERSION
    ):
        errors.append(
            "invalid schema_version"
        )

    if (
        "status" in artifact
        and artifact["status"]
        not in VALID_STATUSES
    ):
        errors.append(
            "invalid status"
        )

    if (
        "certified" in artifact
        and not isinstance(
            artifact["certified"],
            bool,
        )
    ):
        errors.append(
            "certified must be boolean"
        )

    if (
        "evidence" in artifact
        and not isinstance(
            artifact["evidence"],
            dict,
        )
    ):
        errors.append(
            "evidence must be object"
        )

    return (
        len(errors) == 0,
        errors,
    )
