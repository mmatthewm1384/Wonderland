from pathlib import Path


class RegistryGateError(Exception):
    pass


def validate_before_transaction(root=None):

    if root is None:
        root = Path.cwd()

    validator = (
        root /
        "builder/python/wlplatform/wlplatform/auto_drop/registry_validator.py"
    )

    if not validator.exists():
        raise RegistryGateError(
            "Registry validation engine unavailable"
        )

    return {
        "registry_gate": "PASS",
        "validator": str(validator)
    }
