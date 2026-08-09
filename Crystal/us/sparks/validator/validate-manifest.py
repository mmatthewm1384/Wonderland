#!/usr/bin/env python

import sys
from pathlib import Path
import yaml


REQUIRED_TOP_LEVEL = [
    "apiVersion",
    "kind",
    "metadata",
    "spec",
]


def fail(message):
    print(f"[FAIL] {message}")
    sys.exit(1)


def main():

    if len(sys.argv) != 2:
        fail("usage: validate-manifest.py <manifest.yaml>")

    manifest = Path(sys.argv[1])

    if not manifest.exists():
        fail(f"missing manifest: {manifest}")

    with open(manifest) as f:
        data = yaml.safe_load(f)


    for key in REQUIRED_TOP_LEVEL:
        if key not in data:
            fail(f"missing required field: {key}")


    if data["kind"] != "Spark":
        fail("kind must be Spark")


    metadata = data["metadata"]

    if "id" not in metadata:
        fail("missing metadata.id")


    spec = data["spec"]


    runtime = spec.get("runtime")

    if not runtime:
        fail("missing runtime definition")


    if runtime.get("provider") != "lima":
        fail("unsupported runtime provider")


    image = spec.get("image", {}).get("path")

    if not image:
        fail("missing image path")


    capabilities = spec.get("capabilities")

    if not isinstance(capabilities, list):
        fail("capabilities must be a list")


    print("[PASS] Spark manifest valid")
    print()
    print(f"Spark: {metadata['id']}")
    print(f"Runtime: {runtime['provider']}")
    print(f"Image: {image}")


if __name__ == "__main__":
    main()
