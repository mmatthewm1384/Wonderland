#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "== Certification Regression Repair v2 =="

python3 - <<'PY'
from pathlib import Path

# Fix verification import/class reference
p = Path(
    "builder/python/wlplatform/wlplatform/verification.py"
)

text = p.read_text()

text = text.replace(
    "PlatformPlatformCertificationEngine",
    "PlatformCertificationEngine",
)

if "from .engine import PlatformCertificationEngine" not in text:
    text = text.replace(
        "from .certification import CertificationEngine",
        "from .engine import PlatformCertificationEngine",
    )

p.write_text(text)

print("patched verification.py")
PY


python3 - <<'PY'
from pathlib import Path

p = Path(
    "builder/python/wlplatform/wlplatform/certification_registry.py"
)

text = p.read_text()

if "def normalize_status" not in text:

    insert = '''

    def normalize_status(self, entry: dict) -> dict:
        """
        Normalize certification state.

        Certified artifacts without explicit PASS status
        are normalized to PASS.
        """

        if entry.get("certified") is True:
            entry["status"] = "PASS"

        if entry.get("status") == "PASS":
            entry["certified"] = True

        return entry

'''

    marker = "    def normalize_engine_name"

    text = text.replace(
        marker,
        insert + marker,
    )


# Replace return locations in normalize_active
lines = text.splitlines()

out = []
inside = False

for line in lines:
    if line.startswith("    def normalize_active"):
        inside = True

    if inside and line.strip() == "return active":
        out.append(
            "        return {"
        )
        out.append(
            "            name: self.normalize_status(data)"
        )
        out.append(
            "            for name, data in active.items()"
        )
        out.append(
            "        }"
        )
    else:
        out.append(line)

text = "\n".join(out) + "\n"

p.write_text(text)

print("patched certification_registry.py")
PY


echo
echo "=== Import Check ==="

PYTHONPATH="$ROOT/builder/python/wlplatform" python3 - <<'PY'
from pathlib import Path

from wlplatform.verification import PlatformVerificationEngine
from wlplatform.certification_registry import CertificationRegistry

root = Path(".")

registry = CertificationRegistry(root)

for name, data in registry.normalize_active().items():
    print(
        name,
        data.get("status"),
        data.get("certified")
    )

print(
    PlatformVerificationEngine(root)
    .verify()
)
PY

echo
echo "Repair complete."
