#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$WL_ROOT"

echo "=============================================="
echo "Certification Evidence Resolver v1.1"
echo "=============================================="


MODULE_DIR="builder/python/wlplatform/wlplatform/certification"

RESOLVER="$MODULE_DIR/evidence.py"


cat > "$RESOLVER" <<'PYTHON'
"""
Certification Evidence Resolver

Discovers certification evidence through
certification-owned artifact boundaries.
"""

from pathlib import Path


class EvidenceResolver:

    def __init__(self, root):

        self.root = Path(root).resolve()


    def certification_root(self):

        return (
            self.root
            /
            "vault"
            /
            "08-Operations"
            /
            "certifications"
        )


    def normalized_root(self):

        return (
            self.certification_root()
            /
            "normalized"
        )


    def resolve_engine_artifact(self, engine):

        artifact = (
            self.normalized_root()
            /
            f"{engine}.json"
        )

        return artifact if artifact.exists() else None


    def resolve_all(self):

        root = self.normalized_root()

        if not root.exists():
            return []

        return sorted(
            [
                path
                for path in root.glob("*.json")
            ]
        )
PYTHON


TEST_FILE="builder/python/wlplatform/tests/test_certification_evidence_resolver.py"


cat > "$TEST_FILE" <<'PYTEST'
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
PYTEST


echo
echo "Running evidence resolver verification..."

python3 -m pytest \
"$TEST_FILE" \
-v


echo
echo "Certification Evidence Resolver PASS"
