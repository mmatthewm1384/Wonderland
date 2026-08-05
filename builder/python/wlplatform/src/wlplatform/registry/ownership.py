from pathlib import Path


REGISTRY_INDEX = (
    "vault/05-Registry/auto-drop/package-index.json"
)


def assert_registry_owner(path: Path):

    path = Path(path)

    forbidden = [
        "scripts/auto-drop",
    ]

    value = str(path)

    for item in forbidden:

        if item in value:

            raise RuntimeError(
                f"Registry index write denied outside RegistryService: {path}"
            )


def registry_index_path(root):

    return (
        Path(root) /
        REGISTRY_INDEX
    )
