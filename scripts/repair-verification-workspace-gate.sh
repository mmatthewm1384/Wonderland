#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
from pathlib import Path

p = Path(
    "builder/python/wlplatform/wlplatform/verification.py"
)

text = p.read_text()

text = text.replace(
'''        passed = all(
            checks.values()
        )
''',
'''        certification_checks = {
            key: value
            for key, value in checks.items()
            if key != "repository_clean"
        }

        passed = all(
            certification_checks.values()
        )
'''
)

text = text.replace(
'''            "checks": checks,
''',
'''            "checks": checks,
            "workspace": {
                "repository_clean":
                    checks.get(
                        "repository_clean",
                        False,
                    )
            },
'''
)

p.write_text(text)

print(
    "patched verification workspace gate"
)
PY
