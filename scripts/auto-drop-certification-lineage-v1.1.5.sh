#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"

echo "== Wonderland Certification Transaction Repair v1.1.5 =="


CERT="builder/python/wlplatform/wlplatform/certification.py"
TRUST="builder/python/wlplatform/wlplatform/certification_trust.py"


echo "[1/5] Add isolated trust bootstrap"


python3 <<'PY'
from pathlib import Path

p=Path(
"builder/python/wlplatform/wlplatform/certification_trust.py"
)

s=p.read_text()

old='''graph = self.load_graph()

        if graph is None:
            raise RuntimeError(
                "Certification graph missing"
            )
'''

new='''graph = self.load_graph()

        if graph is None:

            graph_path = (
                self.root /
                "vault/08-Operations/certifications/graph/trust-state.json"
            )

            graph_path.parent.mkdir(
                parents=True,
                exist_ok=True
            )

            graph = {
                "schema_version": 1,
                "nodes": {},
                "edges": []
            }

            graph_path.write_text(
                json.dumps(
                    graph,
                    indent=2
                )
            )
'''

if old in s:
    s=s.replace(old,new)

p.write_text(s)

PY


echo "[2/5] Preserve explicit root"


python3 <<'PY'
from pathlib import Path

p=Path(
"builder/python/wlplatform/wlplatform/certification.py"
)

s=p.read_text()


s=s.replace(
'''
root = Path(
    "/Users/wonderland/Wonderland"
)
''',
'''
if root is None:
    root = Path(
        "/Users/wonderland/Wonderland"
    )
else:
    root = Path(root)
'''
)


p.write_text(s)

PY


echo "[3/5] Add controller validation"


python3 <<'PY'
from pathlib import Path

p=Path(
"builder/python/wlplatform/wlplatform/certification.py"
)

s=p.read_text()

if "controller is None" not in s:

    marker="def certify"

    idx=s.find(marker)

    start=s.find("\n",idx)+1

    s=s[:start]+'''
    if controller is None:
        raise CertificationError(
            "controller required"
        )

'''+s[start:]

p.write_text(s)

PY


echo "[4/5] Return artifact metadata"


python3 <<'PY'
from pathlib import Path

p=Path(
"builder/python/wlplatform/wlplatform/certification.py"
)

s=p.read_text()

if '"artifact"' not in s:

    s=s.replace(
        "return result",
        """
result["artifact"] = str(
    Path(root) /
    "vault/08-Operations/certifications/platform-certification.json"
)

return result
"""
    )

p.write_text(s)

PY


echo "[5/5] Regression"

export PYTHONPATH="$ROOT/builder/python"

python3 -m pytest \
builder/python/wlplatform/tests \
tests/regression/test-certification-lineage-v112.py \
-q
