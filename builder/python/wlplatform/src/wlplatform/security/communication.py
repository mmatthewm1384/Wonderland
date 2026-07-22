from pathlib import Path
import yaml


def load_providers():
    root = Path(__file__).resolve()

    for parent in root.parents:
        candidate = (
            parent /
            "security" /
            "providers" /
            "communication_providers.yaml"
        )

        if candidate.exists():
            with open(candidate) as f:
                return yaml.safe_load(f)

    return {"providers": {}}


def providers():
    data = load_providers()

    for name, provider in data.get("providers", {}).items():
        print(f"{name}")
        print(f"  trust: {provider.get('trust_level')}")
        print(f"  identity: {provider.get('identity_model')}")
        print()
