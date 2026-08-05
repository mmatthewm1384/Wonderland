from pathlib import Path
import json

from .ownership import registry_index_path


class PackageIndex:

    def __init__(self, root):

        self.path = registry_index_path(
            root
        )


    def load(self):

        if not self.path.exists():

            return {
                "schema_version": 1,
                "packages": {}
            }

        return json.loads(
            self.path.read_text()
        )


    def save(self, data):

        self.path.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        self.path.write_text(
            json.dumps(
                data,
                indent=2
            )
        )
