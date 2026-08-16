from pathlib import Path
import sys

from wlplatform.paths import repository_root


ROOT = repository_root()

SOURCE_ROOT = (
    ROOT /
    "builder/python/wlplatform/src"
)

sys.path.insert(
    0,
    str(SOURCE_ROOT)
)


from wlplatform.registry.registry_service import RegistryService


def main():

    if len(sys.argv) < 4:
        raise SystemExit(
            "usage: registry_cli.py ROOT COMMAND PACKAGE"
        )

    root = Path(sys.argv[1])

    command = sys.argv[2]

    package = sys.argv[3]

    registry = RegistryService(root)


    if command == "verify-dependencies":

        result = registry.verify_dependencies(
            package
        )

        print(result)

        return


    raise SystemExit(
        f"unknown registry command: {command}"
    )


if __name__ == "__main__":
    main()
