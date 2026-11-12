#!/usr/bin/env python3
"""Validate YAML syntax and trigger conditions for GitHub Actions workflows."""

import sys
from pathlib import Path

import yaml

WORKFLOWS_DIR = Path(".github/workflows")


def validate_workflows() -> int:
    if not WORKFLOWS_DIR.exists():
        print(f"[-] Workflows directory {WORKFLOWS_DIR} not found.")
        return 1

    workflow_files = list(WORKFLOWS_DIR.glob("*.yml")) + list(
        WORKFLOWS_DIR.glob("*.yaml")
    )
    if not workflow_files:
        print("[!] No workflow files found in .github/workflows/.")
        return 0

    print(f"[*] Validating {len(workflow_files)} workflow(s)...")
    has_error = False

    for wf in workflow_files:
        print(f"\n[+] Inspecting: {wf}")
        try:
            with open(wf, encoding="utf-8") as f:
                data = yaml.safe_load(f)

            if not isinstance(data, dict):
                print("    [FAIL] Root element must be a dictionary/mapping.")
                has_error = True
                continue

            name = data.get("name", wf.name)
            triggers = data.get("on") if "on" in data else data.get(True)
            jobs = data.get("jobs")

            print(f"    - Name: {name}")
            print(
                f"    - Triggers ('on'): {list(triggers.keys()) if isinstance(triggers, dict) else triggers}"
            )
            print(
                f"    - Jobs defined: {list(jobs.keys()) if isinstance(jobs, dict) else 'None'}"
            )

            if not triggers:
                print("    [WARN] Workflow is missing 'on' trigger conditions.")
            else:
                print("    [PASS] Triggers correctly configured.")

            if not jobs or not isinstance(jobs, dict):
                print("    [FAIL] Workflow is missing valid 'jobs' definitions.")
                has_error = True
            else:
                print("    [PASS] YAML syntax and jobs structure valid.")

        except yaml.YAMLError as exc:
            print(f"    [FAIL] YAML parsing error: {exc}")
            has_error = True
        except Exception as exc:
            print(f"    [FAIL] Unexpected error: {exc}")
            has_error = True

    return 1 if has_error else 0


if __name__ == "__main__":
    sys.exit(validate_workflows())
