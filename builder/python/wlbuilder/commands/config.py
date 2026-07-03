from __future__ import annotations

import json
from pathlib import Path

from wlbuilder.config import load_config
from wlbuilder.config_schema import validate_config


def run(repo_root: Path, *, as_json: bool = False) -> int:
    config = load_config(repo_root)
    issues = validate_config(config)
    migration = config.data.get("migration", {})

    if as_json:
        print(
            json.dumps(
                {
                    "path": str(config.path),
                    "default_profile": config.default_profile,
                    "data": config.data,
                    "migration": migration if isinstance(migration, dict) else {},
                    "valid": not issues,
                    "issues": [
                        {"field": issue.field, "message": issue.message}
                        for issue in issues
                    ],
                },
                indent=2,
                sort_keys=True,
            )
        )
        return 1 if issues else 0

    print(f"config_file: {config.path}")
    print(f"default_profile: {config.default_profile}")
    print(f"valid: {str(not issues).lower()}")

    if isinstance(migration, dict):
        print("migration:")
        for name in sorted(migration):
            print(f"  - {name}: {migration[name]}")

    if issues:
        print("issues:")
        for issue in issues:
            print(f"  - {issue.field}: {issue.message}")

    return 1 if issues else 0
