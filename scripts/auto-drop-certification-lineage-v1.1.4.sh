#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"

ENGINE="builder/python/wlplatform/wlplatform/engine.py"
CERT="builder/python/wlplatform/wlplatform/certification.py"

echo "== Wonderland Certification Lineage v1.1.4 =="


echo "[1/5] Patch engine constructor"

python3 <<'PY'
from pathlib import Path

p=Path(
"builder/python/wlplatform/wlplatform/engine.py"
)

s=p.read_text()

if "self.artifact_path =" not in s:

    lines=s.splitlines()

    out=[]
    inside=False
    inserted=False

    for line in lines:

        out.append(line)

        if "def __init__(" in line:
            inside=True

        if inside and (
            "self.root" in line
            and not inserted
        ):
            indent=line[:len(line)-len(line.lstrip())]

            out.extend([
                "",
                f"{indent}self.artifact_path = (",
                f"{indent}    self.root /",
                f'{indent}    "vault/08-Operations/certifications/platform-certification.json"',
                f"{indent})",
                "",
                f"{indent}self.lineage_path = (",
                f"{indent}    self.root /",
                f'{indent}    "vault/08-Operations/certifications/platform-lineage.json"',
                f"{indent})",
            ])

            inserted=True

    if not inserted:
        raise SystemExit(
            "Could not locate root assignment"
        )

    p.write_text("\n".join(out)+"\n")

PY


echo "[2/5] Patch wrapper root handling"


python3 <<'PY'
from pathlib import Path

p=Path(
"builder/python/wlplatform/wlplatform/certification.py"
)

s=p.read_text()

s=s.replace(
"""
print(root)
print("CERTIFICATION ROOT:", root)

root = Path(
    "/Users/wonderland/Wonderland"
)
""",
"""
if root is None:
    root = Path(
        "/Users/wonderland/Wonderland"
    )
else:
    root = Path(root)

print(root)
print("CERTIFICATION ROOT:", root)
"""
)

p.write_text(s)

PY


echo "[3/5] Add artifact write"


python3 <<'PY'
from pathlib import Path

p=Path(
"builder/python/wlplatform/wlplatform/engine.py"
)

s=p.read_text()

if "self.artifact_path.write_text" not in s:

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


echo "[4/5] Verify imports"

export PYTHONPATH="$ROOT/builder/python"


python3 - <<'PY'
from wlplatform.engine import PlatformCertificationEngine

from tempfile import TemporaryDirectory
from pathlib import Path

with TemporaryDirectory() as tmp:

    e=PlatformCertificationEngine(
        Path(tmp)
    )

    print(
        "artifact_path=",
        e.artifact_path
    )

PY


echo "[5/5] Run regression"

python3 -m pytest \
builder/python/wlplatform/tests \
tests/regression/test_certification_lineage_v112.py \
-q
