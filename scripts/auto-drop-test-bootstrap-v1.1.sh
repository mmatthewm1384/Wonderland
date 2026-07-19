#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

echo "== Wonderland Test Bootstrap v1.1 =="

cd "$ROOT"

echo "[1/5] Create pytest configuration"

cat > pytest.ini <<'EOF'
[pytest]
testpaths =
    builder/python
    tests

pythonpath =
    builder/python
    builder/python/wlplatform
    builder/python/wlacademy
    builder/python/wlmirror
    builder/python/wlrepository
    builder/python/wlknowledge
    builder/python/wlgovernance
    builder/python/wldoctor

norecursedirs =
    vault
    .git
    .venv
    build
    dist

addopts =
    --import-mode=importlib
EOF


echo "[2/5] Remove stale pytest cache"

find . \
    -name "__pycache__" \
    -type d \
    -prune \
    -exec rm -rf {} +

find . \
    -name ".pytest_cache" \
    -type d \
    -prune \
    -exec rm -rf {} +


echo "[3/5] Verify package paths"

python3 - <<'PY'
import sys

paths=[
"builder/python",
"builder/python/wlplatform",
"builder/python/wlacademy",
"builder/python/wlmirror",
"builder/python/wlrepository",
"builder/python/wlknowledge",
]

for p in paths:
    if p not in sys.path:
        sys.path.insert(0,p)

print("python path OK")
PY


echo "[4/5] Fix wlknowledge regression indentation"

FILE="builder/python/wlknowledge/tests/test_compile.py"

if grep -q "^root = Path(file)" "$FILE"; then
python3 - <<'PY'
from pathlib import Path

p=Path(
"builder/python/wlknowledge/tests/test_compile.py"
)

text=p.read_text()

text=text.replace(
"\nroot = Path(file).resolve().parents[4]",
"\n    root = Path(file).resolve().parents[4]"
)

p.write_text(text)

print("patched indentation")
PY
fi


echo "[5/5] Run certification regression"

python3 -m pytest \
    builder/python/wlplatform/tests \
    tests/wlknowledge \
    --disable-warnings


echo
echo "== Test Bootstrap Complete =="
