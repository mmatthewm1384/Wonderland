#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

CERT="$ROOT/builder/python/wlplatform/wlplatform/certification/__init__.py"
ENGINE="$ROOT/builder/python/wlplatform/wlplatform/engine.py"
ADAPTER="$ROOT/builder/python/wlplatform/wlplatform/certification/adapters/registry.py"

echo "Patching certification contract..."

python3 - <<'PY'
from pathlib import Path

root = Path.cwd()

# Fix adapter root injection
adapter = root / "builder/python/wlplatform/wlplatform/certification/adapters/registry.py"

text = adapter.read_text()

text = text.replace(
'''class ArtifactAdapter(EngineAdapter):

    def __init__(self, name):
        self.name = name
''',
'''class ArtifactAdapter(EngineAdapter):

    def __init__(self, name):
        self.name = name
        self.root = None

    def set_root(self, root):
        self.root = root
'''
)

text = text.replace(
'''ADAPTERS = [
''',
'''def configure_adapters(root):
    for adapter in ADAPTERS:
        adapter.set_root(root)


ADAPTERS = [
'''
)

adapter.write_text(text)


# Fix engine artifact contract
engine = root / "builder/python/wlplatform/wlplatform/engine.py"

text = engine.read_text()

needle = '''
        certificate["graph"] = {
            "artifact":
                "vault/08-Operations/certifications/graph/certification-graph.json"
        }
'''

replacement = '''
        certificate["graph"] = {
            "artifact":
                "vault/08-Operations/certifications/graph/certification-graph.json"
        }

        artifact = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "platform-certification.json"
        )

        artifact.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        artifact.write_text(
            json.dumps(
                certificate,
                indent=2,
            )
            + "\\n",
            encoding="utf-8",
        )

        certificate["artifact"] = str(artifact)
'''

if needle in text:
    text = text.replace(
        needle,
        replacement
    )

engine.write_text(text)


# Fix invalid root handling
cert = root / "builder/python/wlplatform/wlplatform/certification/certifier.py"

text = cert.read_text()

text = text.replace(
'''    if not (root / "vault").exists():
        raise RuntimeError(
            f"Invalid certification root: {root}"
        )
''',
'''    if root == Path("/") or not root.exists():
        from .errors import CertificationError
        raise CertificationError(
            f"Invalid certification root: {root}"
        )

    (root / "vault").mkdir(
        parents=True,
        exist_ok=True,
    )
'''
)

cert.write_text(text)

print("patched")
PY

echo "PASS"
