#!/usr/bin/env python3

import re
import sys
from pathlib import Path

import yaml


REQUIRED = {
    "apiVersion": "spark.wonderland/v1",
    "kind": "SparkProfile",
}

HOST_PATTERNS = (
    r"/Users/",
    r"/Volumes/",
    r"/private/",
    r"file:///Users/",
    r"file:///Volumes/",
    r"file:///private/",
)

FAIL = False


def fail(message):
    global FAIL
    print(f"[FAIL] {message}")
    FAIL = True


def check(condition, message):
    if condition:
        print(f"[PASS] {message}")
    else:
        fail(message)


def main():
    if len(sys.argv) != 2:
        print("usage: validate-profile.py PROFILE")
        return 2

    profile_path = Path(sys.argv[1]).resolve()

    print("=== Spark Profile Validation ===")
    print(f"Profile: {profile_path}")
    print()

    if not profile_path.is_file():
        fail("profile does not exist")
        return 1

    try:
        data = yaml.safe_load(profile_path.read_text())
    except Exception as exc:
        fail(f"YAML parse error: {exc}")
        return 1

    check(isinstance(data, dict), "document")
    if not isinstance(data, dict):
        return 1

    check(data.get("apiVersion") == REQUIRED["apiVersion"], "apiVersion")
    check(data.get("kind") == REQUIRED["kind"], "kind: SparkProfile")

    metadata = data.get("metadata")
    check(isinstance(metadata, dict), "metadata")

    if isinstance(metadata, dict):
        check(bool(metadata.get("id")), "metadata.id")
        check(metadata.get("version") is not None, "metadata.version")
        check(bool(metadata.get("owner")), "metadata.owner")

    spec = data.get("spec")
    check(isinstance(spec, dict), "spec")

    if not isinstance(spec, dict):
        return 1

    runtime = spec.get("runtime")
    check(isinstance(runtime, dict), "spec.runtime")

    if isinstance(runtime, dict):
        check(runtime.get("provider") == "lima", "runtime.provider")
        check(runtime.get("vmType") in {"vz", "qemu"}, "runtime.vmType")
        check(runtime.get("arch") == "aarch64", "runtime.arch")

    resources = spec.get("resources")
    check(isinstance(resources, dict), "spec.resources")

    if isinstance(resources, dict):
        check(isinstance(resources.get("cpus"), int), "resources.cpus")
        check(bool(resources.get("memory")), "resources.memory")
        check(bool(resources.get("disk")), "resources.disk")

    image = spec.get("image")
    check(isinstance(image, dict), "spec.image")

    if isinstance(image, dict):
        check(bool(image.get("artifact")), "image.artifact")
        check(image.get("type") == "spark-image", "image.type")

    capabilities = spec.get("capabilities")
    check(
        isinstance(capabilities, list) and len(capabilities) > 0,
        "spec.capabilities",
    )

    print()
    print("=== Portability ===")

    text = profile_path.read_text()

    leaked = False

    for pattern in HOST_PATTERNS:
        if re.search(pattern, text):
            print(f"[FOUND] {pattern}")
            leaked = True

    if leaked:
        fail("host-specific paths detected")
    else:
        print("[PASS] No macOS host paths")

    print()

    if FAIL:
        print("[FAIL] Spark profile validation failed")
        return 1

    print("[PASS] Spark profile validation succeeded")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
