from __future__ import annotations

import json

from pathlib import Path


class DependencyGraph:

    def __init__(self, root: Path):

        self.root = Path(root)

        self.path = (
            self.root
            /
            "vault/05-Registry/engines/"
            "dependency-graph.json"
        )


    def load(self):

        return json.loads(
            self.path.read_text()
        )


    def dependencies(
        self,
        engine: str,
    ):

        graph = self.load()

        for item in graph["engines"]:

            if item["name"] == engine:

                return item.get(
                    "depends_on",
                    []
                )

        raise ValueError(
            f"Unknown engine: {engine}"
        )


    def resolve(
        self,
        engine: str,
    ):

        result=[]

        def visit(name):

            if name in result:
                return

            for dep in self.dependencies(name):
                visit(dep)

            result.append(name)


        visit(engine)

        return result
