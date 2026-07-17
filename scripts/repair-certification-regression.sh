#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT"

echo "== Wonderland Certification Regression Repair =="

VERIFY="builder/python/wlplatform/wlplatform/verification.py"
REGISTRY="builder/python/wlplatform/wlplatform/certification_registry.py"

echo "[1/3] Repairing verification engine import..."

python3 - <<'PY'
from pathlib import Path

p = Path(
"builder/python/wlplatform/wlplatform/verification.py"
)

text = p.read_text()

text = text.replace(
    "from .certification import CertificationEngine",
    "from .engine import PlatformCertificationEngine",
)

text = text.replace(
    "CertificationEngine(",
    "PlatformCertificationEngine(",
)

p.write_text(text)

print("verification.py patched")
PY


echo "[2/3] Adding certification normalization..."

python3 - <<'PY'
from pathlib import Path

p = Path(
"builder/python/wlplatform/wlplatform/certification_registry.py"
)

text = p.read_text()

method = '''
    def normalize_status(self, entry: dict) -> dict:
        """
        Normalize certification artifact state.
        """

        status = entry.get("status")
        certified = entry.get(
            "certified",
            False,
        )

        if certified and not status:
            status = "PASS"

        if status == "PASS":
            certified = True

        entry["status"] = status or "UNKNOWN"
        entry["certified"] = certified

        return entry

'''

if "def normalize_status" not in text:
    marker = "\\n    def normalize_engine_name"
    if marker in text:
        text = text.replace(
            marker,
            method + marker,
        )
    else:
        text += "\n" + method


old = "return active"

new = """
return {
            name: self.normalize_status(data)
            for name, data in active.items()
        }
"""

if old in text and new not in text:
    text = text.replace(
        old,
        new,
        1,
    )

p.write_text(text)

print("certification_registry.py patched")
PY


echo "[3/3] Validation..."

PYTHONPATH="$ROOT/builder/python/wlplatform" python3 - <<'PY'
from pathlib import Path

from wlplatform.certification_registry import CertificationRegistry
from wlplatform.verification import PlatformVerificationEngine

root = Path(".")

registry = CertificationRegistry(root)

print("\n=== ENGINE SUMMARY ===")

for name, data in registry.normalize_active().items():
    print(
        f"{name:15} "
        f"status={data.get('status')} "
        f"certified={data.get('certified')}"
    )

print("\n=== VERIFICATION ===")

result = PlatformVerificationEngine(root).verify()

print(result)

PY

echo
echo "Repair complete."
