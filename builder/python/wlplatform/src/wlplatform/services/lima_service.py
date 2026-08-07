#!/usr/bin/env python3
"""
Wonderland Lima Service
"""

from __future__ import annotations

import json
import subprocess
from datetime import UTC, datetime
from pathlib import Path


class LimaService:

    def __init__(
        self,
        root: Path,
        vm_name: str = "wonderland-rootless",
    ):
        self.root = Path(root)
        self.vm_name = vm_name

    def _run(self, command):
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
        )
        return result.stdout.strip()


    def ensure_running(self):
        result = subprocess.run(
            [
                "limactl",
                "start",
                self.vm_name,
            ],
            capture_output=True,
            text=True,
        )

        return result.returncode == 0

    def check_vm_state(self):
        out = self._run(["limactl", "list"])
        return self.vm_name in out and "Running" in out

    def check_mount_policy(self):
        out = self._run(
            [
                "limactl",
                "shell",
                self.vm_name,
                "mount",
            ]
        )
        return "/mnt/shared" in out and "/Users/" not in out

    def check_rootless_runtime(self):
        out = self._run(
            [
                "limactl",
                "shell",
                self.vm_name,
                "nerdctl",
                "info",
            ]
        )
        return "rootless" in out.lower()

    def check_apparmor(self):

        status = self._run(
            [
                "limactl",
                "shell",
                self.vm_name,
                "sudo",
                "aa-status",
            ]
        )

        if "nerdctl-default" in status:
            return True

        load = subprocess.run(
            [
                "limactl",
                "shell",
                self.vm_name,
                "sudo",
                "nerdctl",
                "apparmor",
                "load",
            ],
            capture_output=True,
            text=True,
        )

        if load.returncode != 0:
            return False

        verify = self._run(
            [
                "limactl",
                "shell",
                self.vm_name,
                "sudo",
                "aa-status",
            ]
        )

        return "nerdctl-default" in verify

    def run_checks(self):

        checks = {
            "vm_state": self.check_vm_state(),
            "mount_policy": self.check_mount_policy(),
            "rootless_runtime": self.check_rootless_runtime(),
            "apparmor": self.check_apparmor(),
        }

        return {
            "timestamp": datetime.now(UTC).isoformat(),
            "vm": self.vm_name,
            "checks": checks,
            "certified": all(checks.values()),
        }


    def ensure_apparmor_profile(self):
        """
        Ensure nerdctl AppArmor profile is loaded inside Lima VM.
        """

        import subprocess

        vm_name = getattr(
            self,
            "vm_name",
            "wonderland-rootless",
        )

        check = subprocess.run(
            [
                "limactl",
                "shell",
                vm_name,
                "sudo",
                "aa-status",
            ],
            capture_output=True,
            text=True,
        )

        if "nerdctl-default" in check.stdout:
            return {
                "status": "PASS",
                "apparmor": "nerdctl-default",
                "loaded": True,
            }

        load = subprocess.run(
            [
                "limactl",
                "shell",
                vm_name,
                "--",
                "sudo",
                "nerdctl",
                "apparmor",
                "load",
            ],
            capture_output=True,
            text=True,
        )

        if load.returncode != 0:
            return {
                "status": "FAIL",
                "apparmor": "nerdctl-default",
                "loaded": False,
                "error": load.stderr.strip(),
            }

        verify = subprocess.run(
            [
                "limactl",
                "shell",
                vm_name,
                "--",
                "sudo",
                "aa-status",
            ],
            capture_output=True,
            text=True,
        )

        return {
            "status": (
                "PASS"
                if "nerdctl-default" in verify.stdout
                else "FAIL"
            ),
            "apparmor": "nerdctl-default",
            "loaded": (
                "nerdctl-default"
                in verify.stdout
            ),
        }


    def report(self):

        return self.run_checks()




    

    def normalize_certification_artifact(self, data, phase="start"):
        """
        Convert Lima certification output into canonical schema.
        """

        if "certification" in data:
            return data

        return {
            "component": self.vm_name,
            "phase": phase,
            "timestamp": datetime.now(UTC).isoformat(),
            "certification": data,
        }


    def verify_certification_artifact(self, artifact):
        """
        Verify Wonderland Lima certification artifact integrity.
        """

        import json

        artifact = Path(artifact)

        if not artifact.exists():
            return {
                "verified": False,
                "reason": "artifact_missing",
            }

        try:
            data = json.loads(
                artifact.read_text()
            )
        except Exception as exc:
            return {
                "verified": False,
                "reason": str(exc),
            }

        required = {
            "component",
            "phase",
            "timestamp",
            "certification",
        }

        missing = required.difference(
            data.keys()
        )

        if missing:
            return {
                "verified": False,
                "reason": f"missing_fields:{sorted(missing)}",
            }

        certification = data["certification"]

        return {
            "verified": bool(certification),
            "artifact": str(artifact),
            "component": data["component"],
            "phase": data["phase"],
        }


    def generate_evidence(self):

        results = self.run_checks()

        evidence = (
            self.root
            / "vault"
            / "08-Operations"
            / "evidence"
            / "lima"
        )

        evidence.mkdir(
            parents=True,
            exist_ok=True,
        )

        outfile = (
            evidence
            / (
                "lima-doctor-"
                + datetime.now(
                    UTC
                ).strftime("%Y%m%dT%H%M%SZ")
                + ".json"
            )
        )

        outfile.write_text(
            json.dumps(
                results,
                indent=4,
            )
        )

        return str(outfile)
