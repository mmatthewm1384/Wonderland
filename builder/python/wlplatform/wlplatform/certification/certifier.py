import json
from pathlib import Path
from datetime import datetime, timezone

from .adapters.registry import adapters


def certify(controller=None, include_optional=False, **kwargs):
    """
    Public certification API compatibility boundary.
    """

    root = kwargs.get("root")

    if root is None and controller is not None:
        context = getattr(controller, "context", None)

        if context is not None:
            root = getattr(context, "root", None)

    if root is None:
        root = Path.cwd()

    root = Path(root).expanduser().resolve()

    return _certify_platform(root)


def _certify_platform(root):

    root = Path(root).expanduser().resolve()

    print(f"CERTIFICATION ROOT: {root}")

    if not (root / "vault").exists():
        raise RuntimeError(
            f"Invalid certification root: {root}"
        )

    results = []

    for engine in adapters():

        result = engine.certify()

        results.append(
            result.json()
        )

    status = (
        "PASS"
        if all(
            r["status"] == "PASS"
            for r in results
        )
        else "FAIL"
    )

    artifact = {
        "schema_version": 1,

        "certification":
            "Wonderland Platform Certification",

        "version":
            "1.1",

        "status":
            status,

        "certified":
            status == "PASS",

        "timestamp":
            datetime.now(
                timezone.utc
            ).isoformat(),

        "engines":
        {
            r["engine"]: r["status"]
            for r in results
        },

        "evidence":
            results
    }

    path = (
        root
        /
        "vault"
        /
        "08-Operations"
        /
        "certifications"
        /
        "platform-certification.json"
    )

    path.parent.mkdir(
        parents=True,
        exist_ok=True
    )

    path.write_text(
        json.dumps(
            artifact,
            indent=2
        )
    )

    return artifact
