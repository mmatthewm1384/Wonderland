#!/usr/bin/env python3

from pathlib import Path
import ast


ROOT = Path(
    "builder/python/wlplatform/wlplatform/engines"
)


for path in sorted(ROOT.glob("*.py")):

    if path.name.endswith(".backup"):
        continue

    if path.name.startswith("lineage"):
        continue

    tree = ast.parse(
        path.read_text()
    )

    for node in ast.walk(tree):

        if isinstance(node, ast.FunctionDef):
            if node.name != "verify":
                continue

            returns_dict = False

            for child in ast.walk(node):

                if isinstance(child, ast.Return):
                    if isinstance(
                        child.value,
                        ast.Dict,
                    ):
                        returns_dict = True

            print(
                f"{path.name}: "
                + (
                    "RAW DICT"
                    if returns_dict
                    else "OK"
                )
            )
