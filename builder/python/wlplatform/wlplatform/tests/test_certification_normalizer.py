from wlplatform.certification_normalizer import (
    normalize_certification,
)


def test_normalize_pass_artifact():

    result = normalize_certification(
        {
            "engine": "mirror",
            "status": "PASS",
            "lineage": {
                "artifact_digest":
                    "sha256:test"
            },
        }
    )

    assert result["certified"] is True
    assert result["trust"] == "COMPLETE"
    assert result["lineage_present"] is True
