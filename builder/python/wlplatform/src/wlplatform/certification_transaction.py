from __future__ import annotations

from .certification_integrity import (
    validate_certification_artifact,
    normalize_status,
)


class CertificationTransactionError(
    RuntimeError
):
    pass


def certify_transaction(
    engine,
):
    """
    Verify -> Certify -> Validate -> Commit
    """

    verify_result = engine.certify()

    verify_status = normalize_status(
        verify_result
    )

    if verify_status != "PASS":
        raise CertificationTransactionError(
            f"{engine.name} verification failed: "
            f"{verify_status}"
        )

    certify_result = engine.certify()

    if hasattr(certify_result, "to_dict"):
        artifact = certify_result.to_dict()
    else:
        artifact = dict(certify_result)

    artifact["certified"] = (
        artifact.get("status")
        == "PASS"
    )

    validation = (
        validate_certification_artifact(
            verify_result,
            artifact,
        )
    )

    if not validation["valid"]:
        raise CertificationTransactionError(
            validation["errors"]
        )

    # Keep engine contract intact.
    # write_artifact() expects EngineResult.
    written = engine.write_artifact(
        certify_result
    )

    return {
        "artifact": str(written),
        "validation": validation,
    }
