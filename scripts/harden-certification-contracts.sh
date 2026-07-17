#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "=== Wonderland Certification Contract Hardening ==="

TEST_FILE="builder/python/wlplatform/wlplatform/tests/test_certification_regression.py"

if [ ! -f "$TEST_FILE" ]; then
    echo "ERROR: missing $TEST_FILE"
    exit 1
fi

python3 - <<'PY'
from pathlib import Path

test = Path(
    "builder/python/wlplatform/wlplatform/tests/test_certification_regression.py"
)

text = test.read_text()

addition = r'''

def test_no_certified_engine_without_pass():
    registry = CertificationRegistry(ROOT)

    active = registry.normalize_active()

    failures = [
        name
        for name, engine in active.items()
        if engine.get("certified") is True
        and engine.get("status") != "PASS"
    ]

    assert not failures, (
        "certified engines without PASS status: "
        + ", ".join(failures)
    )
'''

if "test_no_certified_engine_without_pass" not in text:
    text += addition
    test.write_text(text)

print("added certification invariant test")
PY


cat > scripts/audit-engine-contracts.sh <<'AUDIT'
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "=== Engine verify implementations ==="

grep -R "def verify" \
builder/python/wlplatform/wlplatform/engines \
|| true

echo
echo "=== Engines returning raw dictionaries ==="

grep -R "return {" \
builder/python/wlplatform/wlplatform/engines \
|| true

echo
echo "=== Contract audit complete ==="
AUDIT

chmod +x scripts/audit-engine-contracts.sh

echo
echo "Running certification regression..."

python3 -m pytest \
builder/python/wlplatform/wlplatform/tests/test_certification_regression.py

echo
echo "Hardening complete"
