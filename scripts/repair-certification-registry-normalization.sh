#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
from pathlib import Path

p = Path(
    "builder/python/wlplatform/wlplatform/certification_registry.py"
)

text = p.read_text()

old = '''            results[engine] = {
                "engine": engine,
                "artifact": str(
                    path.relative_to(
                        self.root
                    )
                ),
                "certified": True,
                "digest": self.digest(path),
            }
'''

new = '''            import json

            try:
                data = json.loads(
                    path.read_text()
                )
            except Exception:
                data = {}

            results[engine] = self.normalize_status(
                {
                    "engine": engine,
                    "artifact": str(
                        path.relative_to(
                            self.root
                        )
                    ),
                    "status": data.get(
                        "status"
                    ),
                    "certified": data.get(
                        "certified",
                        False,
                    ),
                    "digest": self.digest(path),
                }
            )
'''

if old not in text:
    raise SystemExit(
        "discover block not found"
    )

text = text.replace(
    old,
    new,
)

old2 = '''    def normalize_active(self):

        return self.discover()
'''

new2 = '''    def normalize_active(self):

        active = self.discover()

        return {
            name: self.normalize_status(
                dict(entry)
            )
            for name, entry in active.items()
        }
'''

if old2 not in text:
    raise SystemExit(
        "normalize_active block not found"
    )

text = text.replace(
    old2,
    new2,
)

p.write_text(text)

print(
    "patched certification_registry.py"
)
PY


PYTHONPATH="$ROOT/builder/python/wlplatform" python3 - <<'PY'
from pathlib import Path
from wlplatform.certification_registry import CertificationRegistry

registry = CertificationRegistry(Path("."))

print("=== ENGINE SUMMARY ===")

for name, data in registry.normalize_active().items():
    print(
        f"{name:15} "
        f"status={data.get('status')} "
        f"certified={data.get('certified')}"
    )
PY
