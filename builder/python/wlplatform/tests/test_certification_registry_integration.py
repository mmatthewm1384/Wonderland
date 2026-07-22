"""
Certification Registry Adapter Contract Verification

Ensures certification consumes registry-owned
adapter definitions.
"""


def test_registry_adapter_module_exists():

    from wlplatform.certification.adapters import registry

    assert registry is not None



def test_registry_adapter_factory_exists():

    from wlplatform.certification.adapters import registry

    assert callable(
        registry.adapters
    )



def test_registry_adapter_factory_returns_adapters():

    from wlplatform.certification.adapters import registry

    adapters = registry.adapters()

    assert len(adapters) > 0



def test_registry_certification_adapter_exists():

    from wlplatform.certification.adapters import registry

    adapters = registry.adapters()

    names = [
        adapter.name
        for adapter in adapters
    ]

    assert "registry" in names



def test_registry_adapter_contract():

    from wlplatform.certification.adapters import registry

    adapters = registry.adapters()

    for adapter in adapters:

        assert hasattr(
            adapter,
            "certify"
        )

        assert hasattr(
            adapter,
            "verify"
        )
