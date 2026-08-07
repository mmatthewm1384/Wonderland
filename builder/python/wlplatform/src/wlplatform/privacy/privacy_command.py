from pathlib import Path
import json
import subprocess
from datetime import datetime


def privacy_package(root: Path) -> Path:
    return (
        root
        / "scripts"
        / "auto-drop"
        / "packages"
        / "privacy-foundation-v1"
    )


def evidence_path(root: Path) -> Path:
    return (
        root
        / "vault"
        / "08-Operations"
        / "evidence"
        / "privacy"
    )


def execute(root: Path, command: str):

    package = privacy_package(root)

    if command == "certify":

        script = (
            package
            / "bin"
            / "wl-privacy-certify"
        )

        if not script.exists():
            raise SystemExit(
                f"missing privacy certification package: {script}"
            )

        result = subprocess.run(
            [str(script)],
            cwd=root,
            check=False,
        )

        return result.returncode


    if command == "status":

        evidence = evidence_path(root)

        if not evidence.exists():
            return {
                "status": "UNKNOWN",
                "reason": "no privacy certification evidence found"
            }

        reports = sorted(
            evidence.rglob("*"),
            key=lambda p: p.stat().st_mtime,
            reverse=True,
        )

        return {
            "status": "AVAILABLE",
            "latest_evidence": str(
                reports[0]
            ) if reports else None
        }


    if command == "evidence":

        evidence = evidence_path(root)

        return {
            "evidence_path": str(evidence),
            "exists": evidence.exists(),
            "artifacts": [
                str(p.relative_to(root))
                for p in evidence.rglob("*")
                if p.is_file()
            ] if evidence.exists() else []
        }


    if command == "report":

        evidence = evidence_path(root)

        report = {
            "schema": "wonderland-privacy-report-v1",
            "generated": datetime.utcnow().isoformat() + "Z",
            "evidence_path": str(evidence),
            "exists": evidence.exists(),
        }

        output = (
            root
            / "vault"
            / "08-Operations"
            / "reports"
            / "privacy-report.json"
        )

        output.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        output.write_text(
            json.dumps(
                report,
                indent=2
            )
        )

        return {
            "status": "PASS",
            "report": str(output)
        }


    if command == "verify":

        evidence = evidence_path(root)

        valid = (
            evidence.exists()
            and any(
                evidence.rglob("*")
            )
        )

        return {
            "passed": valid,
            "evidence_path": str(evidence)
        }


    raise SystemExit(
        f"unsupported privacy command: {command}"
    )
