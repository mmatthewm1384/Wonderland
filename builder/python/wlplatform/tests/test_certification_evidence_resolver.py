"""
Certification Evidence Resolver Verification
"""

from pathlib import Path


def test_evidence_resolver_import():

    from wlplatform.certification.evidence import (
        EvidenceResolver
    )

    assert EvidenceResolver is not None



def test_evidence_resolver_root(tmp_path):

    from wlplatform.certification.evidence import (
        EvidenceResolver
    )

    resolver = EvidenceResolver(tmp_path)

    assert (
        resolver.certification_root()
        ==
        tmp_path.resolve()
        /
        "vault"
        /
        "08-Operations"
        /
        "certifications"
    )



def test_missing_artifact_returns_none(tmp_path):

    from wlplatform.certification.evidence import (
        EvidenceResolver
    )

    resolver = EvidenceResolver(tmp_path)

    assert (
        resolver.resolve_engine_artifact(
            "runtime"
        )
        is None
    )



def test_resolve_all_empty(tmp_path):

    from wlplatform.certification.evidence import (
        EvidenceResolver
    )

    resolver = EvidenceResolver(tmp_path)

    assert resolver.resolve_all() == []
