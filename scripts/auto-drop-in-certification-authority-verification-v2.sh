#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

echo "== Certification Authority Verification v2 =="

VERIFY_FILE="builder/python/wlplatform/wlplatform/verification.py"
REGISTRY_FILE="builder/python/wlplatform/wlplatform/certification_registry.py"

echo "[1/5] Patching verification authority..."

python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/verification.py"
)

text = path.read_text()

text = text.replace(
    """from .certification import (
    PlatformCertificationEngine,
)""",
    """from .certification_registry import (
    CertificationRegistry,
)"""
)

text = text.replace(
    """        graph = (
            PlatformCertificationEngine(
                self.root
            )
            .graph()
        )

        checks: dict[str, bool] = {
            "repository_clean":
                self.repository_clean(),
        }

        for engine, state in graph.items():

            checks[
                f"{engine}_certified"
            ] = bool(
                state.get(
                    "certified",
                    False,
                )
            )

        checks[
            "platform_graph_complete"
        ] = all(
            item.get("status")
            != "MISSING"
            for item in graph.values()
        )
""",
    """        registry = CertificationRegistry(
            self.root
        )

        state = registry.load()

        active = state.get(
            "active",
            {}
        )

        checks: dict[str, bool] = {
            "repository_clean":
                self.repository_clean(),
        }

        for engine, artifact in active.items():

            checks[
                f"{engine}_certified"
            ] = (
                artifact.get(
                    "certified",
                    False
                )
                is True
            )

            checks[
                f"{engine}_artifact_valid"
            ] = (
                artifact.get(
                    "digest"
                )
                is not None
            )

        checks[
            "certification_registry_complete"
        ] = bool(active)
"""
)

path.write_text(text)

print("patched verification.py")
PY


echo "[2/5] Checking CertificationRegistry compatibility..."

python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/certification_registry.py"
)

text = path.read_text()

if "def active(self)" not in text:

    marker = "    def load(self):"

    insert = """
    def active(self):

        return self.normalize_active()


"""

    if marker in text:
        text = text.replace(
            marker,
            insert + marker
        )

        path.write_text(text)
        print("added active() compatibility")
    else:
        raise SystemExit(
            "Could not locate load() in CertificationRegistry"
        )

else:
    print("active() already exists")
PY


echo "[3/5] Removing stale python cache..."

find builder/python/wlplatform \
-name "__pycache__" \
-type d \
-exec rm -rf {} +


echo "[4/5] Validating imports..."

PYTHONPATH="$ROOT/builder/python/wlplatform" python3 - <<'PY'
from wlplatform.verification import PlatformVerificationEngine
from wlplatform.certification_registry import CertificationRegistry

print("verification import PASS")
print("registry import PASS")
PY


echo "[5/5] Running verification..."

./bin/wl-platform verify
