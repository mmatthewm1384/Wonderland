from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path



class CertificationError(Exception):
    """
    Raised when Wonderland platform certification fails.
    """

    pass

class PlatformCertificationEngine:

    def __init__(self, root: Path):
        self.root = root.resolve()

        self.cert_dir = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
        )

    def discover(self) -> dict:
        engines = [
            "runtime",
            "repository",
            "builder",
            "governance",
            "doctor",
        ]

        result = {}

        for engine in engines:
            path = (
                self.cert_dir
                / f"{engine}-certification.json"
            )

            if not path.exists():
                result[engine] = {
                    "status": "MISSING",
                    "certified": False,
                    "path": str(path),
                }
                continue

            try:
                data = json.loads(
                    path.read_text(
                        encoding="utf-8"
                    )
                )

                result[engine] = {
                    "status": (
                        "PASS"
                        if data.get("certified")
                        else "FAIL"
                    ),
                    "certified": bool(
                        data.get("certified")
                    ),
                    "path": str(path),
                }

            except Exception as exc:
                result[engine] = {
                    "status": "ERROR",
                    "certified": False,
                    "path": str(path),
                    "error": str(exc),
                }

        return result

    def graph(self) -> dict:
        return self.discover()

    def certify(self) -> dict:

        graph = self.discover()

        certified = all(
            item["certified"]
            for item in graph.values()
        )

        payload = {
            "schema_version": 1,
            "certification":
                "Wonderland Platform Certification",
            "version": "1.0",
            "timestamp":
                datetime.now(
                    timezone.utc
                ).isoformat(),

            "engines": graph,

            "certified": certified,

            "state_digest":
                hashlib.sha256(
                    json.dumps(
                        graph,
                        sort_keys=True,
                    ).encode()
                ).hexdigest(),
        }

        self.cert_dir.mkdir(
            parents=True,
            exist_ok=True,
        )

        artifact = (
            self.cert_dir
            /
            "platform-certification.json"
        )

        artifact.write_text(
            json.dumps(
                payload,
                indent=2,
                sort_keys=True,
            ),
            encoding="utf-8",
        )

        payload["artifact"] = str(artifact)

        return payload


def certify(controller=None, include_optional=False, **kwargs):
    """
    Public certification API.

    CLI entry point delegating to
    PlatformCertificationEngine.
    """

    if controller is None:
        raise CertificationError(
            "Certification requires a platform controller."
        )

    try:
        root = controller.context.root
    except AttributeError as exc:
        raise CertificationError(
            "PlatformController missing context.root"
        ) from exc

    engine = PlatformCertificationEngine(Path(root))

    return engine.certify()

