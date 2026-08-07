from pathlib import Path


def repository_root():
    """
    Locate Wonderland repository root.

    The package may execute from:
        - source tree
        - pytest
        - installed editable package

    Resolve by walking upward from this module.
    """

    current = Path(__file__).resolve()

    for parent in current.parents:
        if (
            (parent / "scripts").is_dir()
            and (parent / "vault").is_dir()
        ):
            return parent

    raise RuntimeError(
        "Unable to locate Wonderland repository root"
    )
