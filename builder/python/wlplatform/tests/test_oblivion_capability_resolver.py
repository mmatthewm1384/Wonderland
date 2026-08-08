from wlplatform.oblivion.capability_resolver import (
    CapabilityResolver,
)


def test_capability_resolver_grants(tmp_path, monkeypatch):

    expected = {
        "type": "capability-attestation",
        "schema_version": 2,
        "subject": {
            "package": "example-package-v1",
            "capability": "artifact.read",
        },
        "decision": {
            "status": "GRANTED",
            "reason": "Capability authorized",
        },
    }

    class FakeRegistryService:

        def __init__(self, root):
            self.root = root

        def capability_request(
            self,
            package,
            capability,
        ):
            return expected

    monkeypatch.setattr(
        "wlplatform.oblivion.capability_resolver.RegistryService",
        FakeRegistryService,
    )

    result = CapabilityResolver(
        tmp_path
    ).resolve(
        "example-package-v1",
        "artifact.read",
    )

    assert result["status"] == "AUTHORIZED"
    assert result["package"] == "example-package-v1"
    assert result["capability"] == "artifact.read"
    assert result["source"] == "registry-trust-v1"
    assert result["attestation"] == expected


def test_capability_resolver_rejects_bad_schema(
    tmp_path,
    monkeypatch,
):

    class FakeRegistryService:

        def __init__(self, root):
            pass

        def capability_request(
            self,
            package,
            capability,
        ):
            return {
                "type": "capability-attestation",
                "schema_version": 1,
                "subject": {
                    "package": package,
                    "capability": capability,
                },
                "decision": {
                    "status": "GRANTED",
                },
            }

    monkeypatch.setattr(
        "wlplatform.oblivion.capability_resolver.RegistryService",
        FakeRegistryService,
    )

    try:
        CapabilityResolver(
            tmp_path
        ).resolve(
            "example-package-v1",
            "artifact.read",
        )
    except RuntimeError as exc:
        assert "schema" in str(exc).lower()
    else:
        raise AssertionError(
            "Expected schema validation failure"
        )
