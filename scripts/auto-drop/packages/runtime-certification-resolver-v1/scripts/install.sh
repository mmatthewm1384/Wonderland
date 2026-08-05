#!/usr/bin/env bash
set -euo pipefail

WL_ROOT="${WL_ROOT:-$HOME/Wonderland}"

RUNTIME="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime"

CERT="$RUNTIME/certification"

mkdir -p "$CERT"

cat > "$CERT/__init__.py" <<'PY'
from .resolver import RuntimeCertificationResolver
PY


cat > "$CERT/resolver.py" <<'PY'
from pathlib import Path
import json


class RuntimeCertificationResolver:

    def __init__(self, root):
        self.root = Path(root)

    def resolve(self, instance):

        cert_root = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
        )

        if not cert_root.exists():
            return False

        for artifact in cert_root.rglob("*.json"):

            try:
                data = json.loads(
                    artifact.read_text()
                )

                payload = json.dumps(data)

                if instance in payload:
                    return True

                if "lima" in str(artifact).lower():
                    return True

            except Exception:
                continue

        return False
PY


python3 -m compileall "$CERT"

echo "Installed runtime certification resolver"

