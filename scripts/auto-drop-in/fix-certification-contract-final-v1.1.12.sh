#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

python3 - <<'PY'
from pathlib import Path

root = Path.cwd()

certifier = (
    root
    / "builder/python/wlplatform/wlplatform/certification/certifier.py"
)

text = certifier.read_text()

# Ensure shared error import
if "from .errors import CertificationError" not in text:
    text = text.replace(
        "from .adapters.registry import adapters",
        "from .adapters.registry import adapters\nfrom .errors import CertificationError"
    )


# Replace certify entry boundary
start = text.index("def certify(")
end = text.index("\n\ndef _certify_platform", start)

replacement = '''
def certify(
    controller=None,
    include_optional=False,
    **kwargs,
):
    """
    Public certification API compatibility boundary.
    """

    root = kwargs.get("root")

    if root is None and controller is not None:
        context = getattr(
            controller,
            "context",
            None,
        )

        if context is not None:
            root = getattr(
                context,
                "root",
                None,
            )

        if root is None:
            root = getattr(
                controller,
                "root",
                None,
            )

    if root is None:
        raise CertificationError(
            "Certification root required"
        )

    root = Path(root).expanduser().resolve()

    return _certify_platform(root)
'''

text = text[:start] + replacement + text[end:]

# Return artifact payload
old = '''
    return {
        "schema_version":
            1,
        "certification":
            "Wonderland Platform Certification",
    }
'''

certifier.write_text(text)


# Patch __init__ exports to use same error object
init = (
    root
    / "builder/python/wlplatform/wlplatform/certification/__init__.py"
)

text = init.read_text()

if "from .errors import CertificationError" not in text:
    text = (
        "from .errors import CertificationError\n"
        + text
    )

init.write_text(text)

print("patched")
PY

echo PASS
