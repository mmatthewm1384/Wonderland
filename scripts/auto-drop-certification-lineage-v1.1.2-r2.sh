set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

cd "$ROOT"

echo
echo "=========================================="
echo " Wonderland Certification Repair v1.1.2-r2"
echo "=========================================="
echo

CERT_FILE="builder/python/wlplatform/wlplatform/certification/init.py"
TRUST_FILE="builder/python/wlplatform/wlplatform/certification_trust.py"
ENGINE_FILE="builder/python/wlplatform/wlplatform/engine.py"

STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p
vault/08-Operations/backups

cp "$CERT_FILE"
"vault/08-Operations/backups/certification-init-${STAMP}.py"

cp "$TRUST_FILE"
"vault/08-Operations/backups/certification-trust-${STAMP}.py"

cp "$ENGINE_FILE"
"vault/08-Operations/backups/engine-${STAMP}.py"

echo
echo "[1/5] Patching certification root ownership..."

python3 <<'PY'
from pathlib import Path
import re

path = Path(
"builder/python/wlplatform/wlplatform/certification/init.py"
)

text = path.read_text()

Remove hardcoded repository-root override.

text = text.replace(
'print("/Users/wonderland/Wonderland")',
''
)

text = text.replace(
'print(f"CERTIFICATION ROOT: /Users/wonderland/Wonderland")',
''
)

Detect common bad assignments.

text = text.replace(
'root = ROOT',
'# root = ROOT'
)

text = text.replace(
'root = repository_root()',
'# root = repository_root()'
)

path.write_text(text)
print("patched certification root ownership")
PY

echo
echo "[2/5] Patching trust graph bootstrap..."

python3 <<'PY'
from pathlib import Path

path = Path(
"builder/python/wlplatform/wlplatform/certification_trust.py"
)

text = path.read_text()

needle = "self.output_path.write_text("

if needle in text and "self.output_path.parent.mkdir" not in text:

text = text.replace(
    needle,
    '''

self.output_path.parent.mkdir(
parents=True,
exist_ok=True,
)

''' + needle,
1,
)

path.write_text(text)

print("patched trust graph bootstrap")
PY

echo
echo "[3/5] Patching engine root validation..."

python3 <<'PY'
from pathlib import Path

path = Path(
"builder/python/wlplatform/wlplatform/engine.py"
)

text = path.read_text()

if "Filesystem root not allowed" not in text:

marker = "self.root = root.resolve()"

if marker in text:

    replacement = """

root = root.resolve()

    if root == Path("/"):
        raise RuntimeError(
            "Filesystem root not allowed"
        )

    self.root = root

"""

    text = text.replace(
        marker,
        replacement,
        1,
    )

path.write_text(text)

print("patched root validation")
PY

echo
echo "[4/5] Creating certification bootstrap tree..."

mkdir -p
vault/08-Operations/certifications/graph

if [[ ! -f
vault/08-Operations/certifications/graph/trust-state.json
]]
then

cat >
vault/08-Operations/certifications/graph/trust-state.json <<'JSON'
{
"schema_version": 1,
"nodes": {},
"edges": []
}
JSON

fi

echo
echo "[5/5] Running certification regression..."

PYTHON=".venv/bin/python"

if [[ ! -x "$PYTHON" ]]
then
echo
echo "ERROR: Wonderland virtual environment missing"
exit 1
fi

"$PYTHON" -m pytest -q
builder/python/wlplatform/tests/test_certification.py
builder/python/wlplatform/tests/test_certification_root.py
tests/regression/test_certification_lineage_v112.py

echo
echo "Done."
echo
