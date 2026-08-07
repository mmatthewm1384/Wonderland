from __future__ import annotations

from pathlib import Path


def create_profile(root, name):

    root = Path(root)

    profile = f"""# Wonderland Spark Alpine Runtime
# Generated: {name}

images:
  - location: https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/aarch64/alpine-virt-3.20.3-aarch64.iso

cpus: 2
memory: 2GiB
disk: 10GiB

mounts: []

containerd:
  system: false
  user: true
"""

    path = (
        root /
        "Crystal/us/sparks" /
        f"{name}.yaml"
    )

    path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    path.write_text(profile)

    return str(path)
