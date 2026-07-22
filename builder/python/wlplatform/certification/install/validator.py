from pathlib import Path
import importlib


class InstallationResult:


    def __init__(self):

        self.checks = {}
        self.certified = False



    def add(self, name, result):

        self.checks[name] = result



    def finalize(self):

        self.certified = all(
            self.checks.values()
        )

        return self



def validate_engine(
    root,
    package,
    modules,
    tests_path,
    certification_path
):

    result = InstallationResult()


    package_path = Path(root) / package.replace(
        ".",
        "/"
    )

    result.add(
        "package_exists",
        package_path.exists()
    )


    for module in modules:

        try:

            importlib.import_module(
                module
            )

            result.add(
                f"import_{module}",
                True
            )

        except Exception:

            result.add(
                f"import_{module}",
                False
            )


    result.add(
        "tests_exist",
        Path(tests_path).exists()
    )


    result.add(
        "certification_exists",
        Path(certification_path).exists()
    )


    return result.finalize()
