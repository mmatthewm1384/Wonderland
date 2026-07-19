#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

echo "== Wonderland Certification Lineage v1.1.2 Auto Drop-In =="

ENGINE="builder/python/wlplatform/wlplatform/engine.py"
TRUST="builder/python/wlplatform/wlplatform/certification_trust.py"
CERT="builder/python/wlplatform/wlplatform/certification/__init__.py"

echo "[1/5] Patch engine root validation"

python3 <<'PY'
from pathlib import Path

p = Path("builder/python/wlplatform/wlplatform/engine.py")
s = p.read_text()

old = """    def __init__(self, root: Path):
        self.root = root.resolve()
"""

new = """    def __init__(self, root: Path):
        self.root = root.resolve()

        if self.root == Path("/"):
            raise RuntimeError(
                "Certification root cannot be filesystem root"
            )
"""

if old in s:
    s = s.replace(old, new)

p.write_text(s)
PY


echo "[2/5] Add trust graph bootstrap"

python3 <<'PY'
from pathlib import Path

p = Path(
    "builder/python/wlplatform/wlplatform/certification_trust.py"
)

s = p.read_text()

if "import json" not in s:
    s = "import json\n" + s

old = """        if not path.exists():
            return None
"""

new = """        path.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        if not path.exists():
            path.write_text(
                json.dumps(
                    {
                        "schema_version": 1,
                        "nodes": {},
                        "edges": []
                    },
                    indent=2
                )
            )

        return json.loads(
            path.read_text()
        )
"""

if old in s:
    s = s.replace(old, new)

p.write_text(s)
PY


echo "[3/5] Patch certification controller resolution"

python3 <<'PY'
from pathlib import Path

p = Path(
    "builder/python/wlplatform/wlplatform/certification/__init__.py"
)

s = p.read_text()

needle = """def certify(controller=None, include_optional=False, **kwargs):
"""

patch = """
def certify(controller=None, include_optional=False, **kwargs):

    if controller is None and "root" not in kwargs:
        raise CertificationError(
            "Certification controller required"
        )

    if controller is not None:
        root = (
            getattr(controller, "root", None)
            or getattr(controller, "path", None)
        )

        if root is None:
            raise CertificationError(
                "Controller has no certification root"
            )

        kwargs["root"] = root

"""

if needle in s and patch not in s:
    s = s.replace(needle, patch)

p.write_text(s)
PY


echo "[4/5] Ensure artifact write directory"

python3 <<'PY'
from pathlib import Path

p = Path(
    "builder/python/wlplatform/wlplatform/engine.py"
)

s = p.read_text()

needle = """        systems = self.discover()
"""

replacement = """        systems = self.discover()

        self.artifact_path.parent.mkdir(
            parents=True,
            exist_ok=True
        )
"""

if needle in s and replacement not in s:
    s = s.replace(
        needle,
        replacement,
        1
    )

p.write_text(s)
PY


echo "[5/5] Run certification regression"

pytest -q \
builder/python/wlplatform/tests/test_certification.py \
builder/python/wlplatform/tests/test_certification_root.py \
tests/regression/test_certification_lineage_v112.py


echo
echo "== Certification Lineage v1.1.2 COMPLETE =="
