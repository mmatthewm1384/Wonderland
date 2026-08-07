from __future__ import annotations

import json
from pathlib import Path

from .models import Spark


class SparkRegistry:

    def __init__(self, root):
        self.root = Path(root)
        self.path = (
            self.root /
            "Crystal/us/sparks/registry.json"
        )

        self.path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        if not self.path.exists():
            self.path.write_text("{}")


    def load(self):
        return json.loads(
            self.path.read_text()
        )


    def save(self, data):
        self.path.write_text(
            json.dumps(
                data,
                indent=2,
            )
        )


    def create(self, spark: Spark):

        data = self.load()

        data[spark.name] = spark.to_dict()

        self.save(data)

        return spark.to_dict()


    def list(self):
        return self.load()
