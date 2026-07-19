from __future__ import annotations


def normalize_certification(
    artifact: dict,
) -> dict:

    status = artifact.get(
        "status",
        "UNKNOWN",
    )

    lineage = artifact.get(
        "lineage"
    )

    certified = (
        artifact.get(
            "certified",
            False,
        )
        or
        status == "PASS"
    )

    trust = (
        "COMPLETE"
        if certified
        and lineage
        else
        "INCOMPLETE"
    )

    return {
        "engine": artifact.get(
            "engine"
        ),

        "status": status,

        "certified": certified,

        "trust": trust,

        "digest": (
            lineage.get(
                "artifact_digest"
            )
            if lineage
            else None
        ),

        "lineage_present":
            lineage is not None,
    }
