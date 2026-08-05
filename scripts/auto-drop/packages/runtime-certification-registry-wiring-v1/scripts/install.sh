#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/targets/loader.py"

BACKUP="$TARGET.runtime-certification-registry-wiring-v1.bak"

if [[ ! -f "$BACKUP" ]]; then
    cp "$TARGET" "$BACKUP"
fi

python3 - <<PY
from pathlib import Path

p = Path("$TARGET")

text = p.read_text()

if "_certification_status" in text:
    print("Certification resolver already present")
    exit(0)

insert = '''

    def _certification_status(self, target_id):
        from pathlib import Path
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

marker = "class RuntimeTargetRegistry"

if marker not in text:
    raise SystemExit("RuntimeTargetRegistry class not found")

text = text.replace(
    marker,
    marker + insert
)

text = text.replace(
    '"certified": False',
    '"certified": self._certification_status(target_id)'
)

p.write_text(text)

print("Certification resolver wired")
PY

mkdir -p "$WL_ROOT/vault/08-Operations/certifications/runtime"

cat > "$WL_ROOT/vault/08-Operations/certifications/runtime/runtime-certification-registry-wiring-v1.json" <<JSON
{
  "component": "runtime",
  "adapter": "registry-certification-wiring",
  "status": "installed",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
JSON

echo "Installed"
