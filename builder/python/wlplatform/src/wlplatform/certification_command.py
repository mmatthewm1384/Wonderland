from __future__ import annotations

from pathlib import Path

from .certification_coverage import certification_coverage


def certification_gate(root: Path):

    engines = [
        "mirror",
        "registry",
        "architecture",
        "builder",
        "governance",
        "academy",
        "runtime",
    ]

    coverage = certification_coverage(
        root,
        engines,
    )

    failures = []

    for item in coverage["engines"]:

        if not item.get(
            "artifact_exists",
            False,
        ):
            failures.append(
                f'{item["engine"]}: missing artifact'
            )

        if item.get(
            "status"
        ) != "PASS":
            failures.append(
                f'{item["engine"]}: status={item.get("status")}'
            )

        if not item.get(
            "certified",
            False,
        ):
            failures.append(
                f'{item["engine"]}: uncertified'
            )

    return {
        "command": "certification gate",
        "result":
            "PASS"
            if not failures
            else "FAIL",
        "failures": failures,
        "coverage": coverage,
    }
