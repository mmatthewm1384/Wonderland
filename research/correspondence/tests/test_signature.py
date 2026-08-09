from research.correspondence.signature import TransformationSignature


def test_signature_is_deterministic():
    sig = TransformationSignature("earth-test", "synthetic", {}, {}, {}, {}, {}, {})
    assert sig.canonical_json() == sig.canonical_json()
