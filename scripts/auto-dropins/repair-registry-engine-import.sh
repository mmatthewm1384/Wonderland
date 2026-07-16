#!/usr/bin/env bash
set -euo pipefail

echo "== Wonderland Registry Engine Import Repair =="

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

TARGET="builder/python/wlplatform/wlplatform/engines.py"

BACKUP="${TARGET}.bak.registry-import.$(date +%Y%m%d-%H%M%S)"

cp "$TARGET" "$BACKUP"

echo "Backup:"
echo "$BACKUP"

python3 - <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlplatform/wlplatform/engines.py"
)

text = path.read_text()

text = text.replace(
    "from .engines.registry import RegistryEngine",
    ""
)

if "class RegistryEngine" not in text:

    text += """



class RegistryEngine(EngineContract):

    name = "registry"

    def verify(self):

        registry = (
            self.root
            /
            "vault/05-Registry"
        )

        exists = registry.exists()

        return EngineResult(
            engine=self.name,
            action="verify",
            status=(
                "PASS"
                if exists
                else "FAIL"
            ),
            details={
                "registry_root": str(registry),
                "exists": exists,
            },
        )

"""

path.write_text(text)

PY

echo "Running import verification..."

python3 - <<'PY'
from wlplatform.engines import get_engine

engine = get_engine(
    "registry",
    ".",
)

print(type(engine).__name__)
PY

echo "== PASS =="
