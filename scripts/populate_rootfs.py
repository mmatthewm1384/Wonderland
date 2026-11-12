#!/usr/bin/env python3
import subprocess
import sys
import tempfile


def main():
    if len(sys.argv) < 2:
        print("Error: Target image path required", file=sys.stderr)
        sys.exit(1)

    img_path = sys.argv[1]
    with tempfile.TemporaryDirectory() as tmpdir:
        # Extract container tarball stream into temp staging dir
        subprocess.run(["tar", "-xf", "-", "-C", tmpdir], check=True)
        print(f"Staged rootfs contents at {tmpdir}. Populating image {img_path}...")


if __name__ == "__main__":
    main()
