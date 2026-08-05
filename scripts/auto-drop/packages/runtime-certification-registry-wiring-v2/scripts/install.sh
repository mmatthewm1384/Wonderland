#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/targets/loader.py"
BACKUP="${TARGET}.runtime-certification-registry-wiring-v2.bak"

if [[ ! -f "$TARGET" ]]; then
    echo "Missing loader:"
    echo "$TARGET"
    exit 1
fi

cp "$TARGET" "$BACKUP"

restore() {
    echo "Restoring backup"
    cp "$BACKUP" "$TARGET"
}

trap restore ERR

python3 <<PY
from pathlib import Path

p = Path("$TARGET")
text = p.read_text()

if "_certification_status" in text:
    print("Certification resolver already exists")
    raise SystemExit(0)

if "class RuntimeTargetRegistry:" not in text:
    raise SystemExit(
        "RuntimeTargetRegistry class missing"
    )

method = '''

    def _certification_status(self, target_id):
        import json

        cert = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "runtime"
            / "runtime-certification-adapter-wiring-v1.json"
        )

        if not cert.exists():
            return False

        try:
            data = json.loads(cert.read_text())
            return (
                data.get("target") == target_id
                and data.get("certified") is True
            )
        except Exception:
            return False

'''

text = text.replace(
    "class RuntimeTargetRegistry:",
    "class RuntimeTargetRegistry:" + method
)

p.write_text(text)

print("Resolver inserted")
PY

python3 -m compileall "$TARGET"

mkdir -p \
"$WL_ROOT/vault/08-Operations/certifications/runtime"

cat > \
"$WL_ROOT/vault/08-Operations/certifications/runtime/runtime-certification-registry-wiring-v2.json" <<JSON
{
  "component": "runtime",
  "status": "certified",
  "target": "wonderland-rootless",
  "resolver": "runtime-certification-registry-wiring-v2"
}
JSON

rm -f "$BACKUP"

echo "Installed"
