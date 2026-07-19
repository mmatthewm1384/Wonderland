#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"

echo "== Wonderland Certification Lineage v1.1.3 Contract Repair =="


ENGINE="$ROOT/builder/python/wlplatform/wlplatform/engine.py"
CERT="$ROOT/builder/python/wlplatform/wlplatform/certification.py"


echo "[1/6] Locate engine constructor"

python3 <<'PY'
from pathlib import Path

p = Path(
"builder/python/wlplatform/wlplatform/engine.py"
)

s = p.read_text()

if "artifact_path" not in s:

    marker = "self.root = Path(root)"

    if marker not in s:
        raise SystemExit(
            "ERROR: constructor marker missing"
        )

    replacement = """
self.root = Path(root)

self.artifact_path = (
    self.root /
    "vault/08-Operations/certifications/platform-certification.json"
)

self.lineage_path = (
    self.root /
    "vault/08-Operations/certifications/platform-lineage.json"
)
"""

    s=s.replace(marker,replacement)

    p.write_text(s)

PY


echo "[2/6] Restore artifact field"


python3 <<'PY'
from pathlib import Path

p=Path(
"builder/python/wlplatform/wlplatform/engine.py"
)

s=p.read_text()

if '"artifact":' not in s:

    needle='"version":\n                self.VERSION,'

    if needle not in s:
        raise SystemExit(
            "ERROR: certificate schema marker missing"
        )

    s=s.replace(
        needle,
        needle+
        '\n            "artifact": str(self.artifact_path),'
    )

p.write_text(s)

PY


echo "[3/6] Restore artifact write"

python3 <<'PY'
from pathlib import Path

p=Path(
"builder/python/wlplatform/wlplatform/engine.py"
)

s=p.read_text()

if "artifact_path.write_text" not in s:

    marker="certificate = {"

    # insert before return if needed
    s=s.replace(
        "return certificate",
        """
self.artifact_path.parent.mkdir(
    parents=True,
    exist_ok=True
)

self.artifact_path.write_text(
    json.dumps(
        certificate,
        indent=2
    )
)

return certificate
"""
    )

p.write_text(s)

PY


echo "[4/6] Fix certify wrapper"


python3 <<'PY'
from pathlib import Path

p=Path(
"builder/python/wlplatform/wlplatform/certification.py"
)

s=p.read_text()

# preserve explicit root
s=s.replace(
"""
root = Path(
    "/Users/wonderland/Wonderland"
)
""",
"""
if root is None:
    root = Path(
        "/Users/wonderland/Wonderland"
    )

root = Path(root)
"""
)

if "controller required" not in s:

    target="def certify("

    idx=s.find(target)

    if idx >=0:
        pass

p.write_text(s)

PY


echo "[5/6] Run focused regression"

export PYTHONPATH="$ROOT/builder/python"

python3 -m pytest \
builder/python/wlplatform/tests \
tests/regression/test_certification_lineage_v112.py \
-q


echo "[6/6] Verify"

test -f \
vault/08-Operations/certifications/platform-certification.json

echo "CERTIFICATION LINEAGE v1.1.3 PASS"
