from __future__ import annotations

import json
from pathlib import Path


class DependencyRegistry:

    def __init__(self, root: Path):

        self.root = Path(root)

        self.path = (
            self.root
            /
            "vault/05-Registry/engines/dependency-graph.json"
        )


    def load(self):

        if not self.path.exists():
            return {}

        payload = json.loads(
            self.path.read_text()
        )

        return payload.get(
            "engines",
            {}
        )


    def dependencies(self, engine):

        graph = self.load()

        entry = graph.get(engine)

        if entry is None:
            raise ValueError(
                f"Unknown engine: {engine}"
            )

        return entry.get(
            "requires",
            []
        )


    def validate(self):

        graph = self.load()

        errors = []

        for engine, data in graph.items():

            for dependency in data.get("requires", []):

                if dependency not in graph:
                    errors.append(
                        {
                            "engine": engine,
                            "missing": dependency
                        }
                    )

        return errors
