from __future__ import annotations

import json
from pathlib import Path
from typing import Any


class CertificationPolicyError(Exception):
    """Certification policy failure."""


class CertificationPolicy:
    """
    Evaluates platform certification completeness.

    Certification execution success and platform certification
    completeness are separate states.
    """


    def __init__(self, root):
        self.root = Path(root).resolve()

        self.path = (
            self.root
            / "policy"
            / "certification"
            / "required-engines.json"
        )


    def load(self) -> dict[str, Any]:

        if not self.path.exists():
            return {
                "required_engines": [],
                "optional_engines": []
            }

        try:
            with self.path.open(
                "r",
                encoding="utf-8"
            ) as handle:
                data = json.load(handle)

        except Exception as exc:
            raise CertificationPolicyError(
                f"Invalid certification policy: {self.path}"
            ) from exc


        if not isinstance(data, dict):
            raise CertificationPolicyError(
                "Certification policy must be an object"
            )

        return data


    def evaluate(
        self,
        engines: dict[str, dict]
    ) -> dict[str, Any]:

        policy = self.load()

        required = policy.get(
            "required_engines",
            []
        )

        certified = []
        missing = []

        for engine in required:

            state = engines.get(engine)

            if (
                state
                and state.get("certified") is True
            ):
                certified.append(engine)

            else:
                missing.append(engine)


        return {
            "required_engines": len(required),
            "certified_engines": len(certified),
            "missing": missing,
            "certified_all": len(missing) == 0
        }
