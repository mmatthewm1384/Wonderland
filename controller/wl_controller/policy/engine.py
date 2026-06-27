from __future__ import annotations

import json
from pathlib import Path


class PolicyEngine:
    def __init__(self, root: Path):
        self.root = root
        self.policy_file = root / "policies/services.json"

    def load(self) -> dict:
        if not self.policy_file.exists():
            return {
                "schema": 1,
                "services": {},
                "valid": False,
                "errors": [f"missing policy file: {self.policy_file}"],
            }

        try:
            data = json.loads(self.policy_file.read_text(encoding="utf-8"))
        except Exception as e:
            return {
                "schema": 1,
                "services": {},
                "valid": False,
                "errors": [str(e)],
            }

        errors: list[str] = []

        if not isinstance(data, dict):
            errors.append("policy root must be object")

        services = data.get("services", {})
        if not isinstance(services, dict):
            errors.append("services must be object")

        for name, policy in services.items():
            if not isinstance(policy, dict):
                errors.append(f"{name}: policy must be object")
                continue

            restart = policy.get("restart", "always")
            if restart not in {"always", "on-failure", "never"}:
                errors.append(f"{name}: invalid restart policy: {restart}")

            depends = policy.get("depends", [])
            if not isinstance(depends, list):
                errors.append(f"{name}: depends must be list")

        data["valid"] = not errors
        data["errors"] = errors
        return data

    def service_policy(self, name: str) -> dict:
        policy = self.load()
        return policy.get("services", {}).get(name, {})

    def validate_dependencies(self, service_names: set[str]) -> dict:
        policy = self.load()
        errors: list[str] = []

        for name, svc in policy.get("services", {}).items():
            for dep in svc.get("depends", []):
                if dep not in service_names:
                    errors.append(f"{name}: missing dependency: {dep}")

        return {
            "valid": not errors and policy.get("valid", False),
            "errors": policy.get("errors", []) + errors,
        }
