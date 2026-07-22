from pathlib import Path


class PackagePlacementError(Exception):
    pass



def get_canonical_package_root(path):

    path = Path(path).resolve()

    for parent in [path] + list(path.parents):

        if (
            parent.name == "wlplatform"
            and (parent / "__init__.py").exists()
            and (parent / "lifecycle").exists()
            and (parent / "recovery").exists()
        ):
            return parent

    return None



def validate_package_target(target):

    target = Path(target).resolve()

    package_root = get_canonical_package_root(target)

    if package_root is None:
        raise PackagePlacementError(
            f"Unable to locate canonical wlplatform package: {target}"
        )


    if target.parent != package_root:

        raise PackagePlacementError(
            "\nInvalid package placement\n"
            f"Target: {target}\n"
            f"Canonical package root: {package_root}\n"
        )


    return {
        "valid": True,
        "package_root": str(package_root),
        "target": str(target)
    }
