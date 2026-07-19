#!/usr/bin/env bash
set -euo pipefail

FILE="builder/python/wlplatform/wlplatform/certification/__init__.py"

python3 - <<'PY'
from pathlib import Path

p = Path("builder/python/wlplatform/wlplatform/certification/__init__.py")

text = p.read_text()

start = text.find("def certify(")

if start == -1:
    raise SystemExit("certify() not found")

header = text[:start]

replacement = r'''def certify(controller=None, include_optional=False, **kwargs):
    """
    Public certification API compatibility boundary.
    """

    root = kwargs.get("root")

    if controller is not None:
        context = getattr(controller, "context", None)

        if context is not None:
            root = getattr(context, "root", None)

        if root is None:
            root = getattr(controller, "root", None)

    if root is None:
        raise CertificationError(
            "Certification root required"
        )

    root = Path(root).expanduser().resolve()

    return _engine_certify(
        root=root,
        include_optional=include_optional,
    )
'''

p.write_text(header + replacement)

print("patched certification/__init__.py")
PY

python3 -m py_compile "$FILE"

echo "PASS"
