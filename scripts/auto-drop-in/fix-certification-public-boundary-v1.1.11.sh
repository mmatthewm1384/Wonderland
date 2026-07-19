#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

FILE="$ROOT/builder/python/wlplatform/wlplatform/certification/__init__.py"

python3 - <<'PY'
from pathlib import Path

p = Path(
"builder/python/wlplatform/wlplatform/certification/__init__.py"
)

text = p.read_text()

start = text.index("def certify(")

end = text.find("\n\n", start)

replacement = '''
def certify(
    controller=None,
    include_optional=False,
    **kwargs,
):

    from .certifier import certify as _certify

    return _certify(
        controller=controller,
        include_optional=include_optional,
        **kwargs,
    )
'''

text = (
    text[:start]
    + replacement
    + text[end:]
)

p.write_text(text)

print("patched certification public boundary")
PY

echo PASS
