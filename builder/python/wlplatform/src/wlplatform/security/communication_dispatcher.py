from pathlib import Path
import yaml


def find_root():
    path = Path(__file__).resolve()

    while path.name != "Wonderland":
        path = path.parent

    return path


def provider_file():
    return (
        find_root()
        / "builder/python/wlplatform/wlplatform/security/providers"
        / "communication_providers.yaml"
    )


def list_providers():
    file = provider_file()

    if not file.exists():
        return {
            "status": "NO_REGISTRY",
            "providers": []
        }

    with open(file) as f:
        return yaml.safe_load(f)


def status():
    return {
        "status": "READY",
        "registry": str(provider_file())
    }


def dispatch(action):

    if action == "providers":
        return list_providers()

    if action == "status":
        return status()

    raise ValueError(
        f"Unknown communication action: {action}"
    )
