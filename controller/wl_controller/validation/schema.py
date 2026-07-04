from __future__ import annotations

import json
from pathlib import Path


class SchemaValidationError(Exception):
    pass


class SchemaValidator:
    def __init__(self, root: Path):
        self.root = root
        self.schemas = root / "schemas"

    def validate_required_keys(self, data: dict, schema_name: str) -> list[str]:
        schema_path = self.schemas / schema_name
        if not schema_path.exists():
            return [f"schema missing: {schema_path}"]

        try:
            schema = json.loads(schema_path.read_text(encoding="utf-8"))
        except Exception as e:
            return [f"schema unreadable: {schema_path}: {e}"]

        errors: list[str] = []

        if not isinstance(data, dict):
            return ["document is not object"]

        for key in schema.get("required", []):
            if key not in data:
                errors.append(f"missing required key: {key}")

        return errors

    def validate_file(self, path: Path, schema_name: str) -> dict:
        if not path.exists():
            return {
                "path": str(path),
                "schema": schema_name,
                "valid": False,
                "errors": ["file missing"],
            }

        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except Exception as e:
            return {
                "path": str(path),
                "schema": schema_name,
                "valid": False,
                "errors": [str(e)],
            }

        errors = self.validate_required_keys(data, schema_name)

        return {
            "path": str(path),
            "schema": schema_name,
            "valid": not errors,
            "errors": errors,
        }

    def validate_platform(self) -> dict:
        checks = [
            self.validate_file(
                self.root / "config/wonderland.json",
                "config.schema.json",
            ),
            self.validate_file(
                self.root / "vault/05-Registry/services.json",
                "services.schema.json",
            ),
            self.validate_file(
                self.root / "vault/05-Registry/desired-state.json",
                "desired-state.schema.json",
            ),
            self.validate_file(
                self.root / "runtime/controller/latest.json",
                "platform-state.schema.json",
            ),
        ]

        valid = all(c["valid"] for c in checks)

        return {
            "valid": valid,
            "checks": checks,
        }
