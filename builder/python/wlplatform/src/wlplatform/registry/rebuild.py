from pathlib import Path
import json


class RegistryRebuilder:

    def __init__(self, root: Path):
        self.root = Path(root)

        self.packages_root = (
            self.root /
            "scripts" /
            "auto-drop" /
            "packages"
        )

        self.index_path = (
            self.root /
            "vault" /
            "05-Registry" /
            "auto-drop" /
            "package-index.json"
        )

    def rebuild(self):

        packages = {}

        if self.packages_root.exists():

            for package_dir in sorted(
                self.packages_root.iterdir()
            ):

                if not package_dir.is_dir():
                    continue

                manifest = package_dir / "manifest.json"

                if not manifest.exists():
                    continue

                data = json.loads(
                    manifest.read_text()
                )

                name = data.get(
                    "name",
                    package_dir.name
                )

                packages[name] = {
                    "version": data.get("version"),
                    "type": data.get("type"),
                    "category": data.get("category"),
                    "dependencies": data.get(
                        "dependencies",
                        []
                    ),
                    "path": str(
                        package_dir.relative_to(
                            self.root
                        )
                    )
                }

        registry = {
            "schema_version": 1,
            "generated": True,
            "packages": packages
        }

        self.index_path.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        self.index_path.write_text(
            json.dumps(
                registry,
                indent=2
            )
        )

        return {
            "status": "PASS",
            "packages": len(packages),
            "index": str(self.index_path)
        }
