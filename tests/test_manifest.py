#!/usr/bin/env python3
import argparse
import difflib
import os
import subprocess
import sys

WORKSPACE_ROOT = os.environ.get("WORKSPACE_ROOT", "/Users/Wonderland/wonderland")
GOLDEN_DIR = os.path.join(WORKSPACE_ROOT, "tests", "golden")
MANIFEST_GOLDEN = os.path.join(GOLDEN_DIR, "rootfs_manifest.golden")
ROOTFS_IMG = os.path.join(WORKSPACE_ROOT, "assets", "rootfs.img")


def get_installed_packages():
    if not os.path.exists(ROOTFS_IMG):
        print(f"[!] Error: RootFS image not found at {ROOTFS_IMG}. Run 'make up' first.")
        sys.exit(1)

    cmd = f"echo 'cat /var/lib/dpkg/status' | /opt/homebrew/opt/e2fsprogs/sbin/debugfs -i {ROOTFS_IMG} 2>/dev/null"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

    packages = []
    for line in result.stdout.splitlines():
        if line.startswith("Package:"):
            packages.append(line.split(":")[1].strip())

    return sorted(list(set(packages)))


def test_manifest(update=False):
    os.makedirs(GOLDEN_DIR, exist_ok=True)
    current_packages = get_installed_packages()

    if not current_packages:
        list_cmd = f"echo 'ls -pR /' | /opt/homebrew/opt/e2fsprogs/sbin/debugfs -i {ROOTFS_IMG} 2>/dev/null"
        res = subprocess.run(list_cmd, shell=True, capture_output=True, text=True)
        current_packages = sorted(
            [line.strip() for line in res.stdout.splitlines() if line.strip()]
        )

    actual_content = "\n".join(current_packages)

    if update or not os.path.exists(MANIFEST_GOLDEN):
        print(f"[+] Writing manifest golden file at {MANIFEST_GOLDEN}")
        with open(MANIFEST_GOLDEN, "w") as f:
            f.write(actual_content)
        print("[PASS] Manifest golden baseline updated successfully.")
        return

    with open(MANIFEST_GOLDEN) as f:
        expected_content = f.read().strip()

    if actual_content == expected_content:
        print("[PASS] RootFS package manifest matches golden reference.")
    else:
        print("[FAIL] RootFS package manifest has drifted from golden reference!\n")
        diff = difflib.unified_diff(
            expected_content.splitlines(),
            actual_content.splitlines(),
            fromfile="golden_manifest",
            tofile="actual_manifest",
            lineterm="",
        )
        print("\n".join(diff))
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run or update rootfs manifest golden test.")
    parser.add_argument(
        "--update",
        action="store_true",
        help="Overwrite golden manifest file with current package state",
    )
    args = parser.parse_args()

    test_manifest(update=args.update)
