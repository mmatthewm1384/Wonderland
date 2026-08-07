from __future__ import annotations

from pathlib import Path
from datetime import UTC, datetime
import json


class SparkRuntimeBuilder:

    def __init__(self, root):

        self.root = Path(root)

        self.spark_dir = (
            self.root /
            "Crystal/us/sparks"
        )

        self.evidence_dir = (
            self.root /
            "Crystal/us/evidence"
        )


    def build(self, name, owner):

        owner_path = owner.lower()

        yaml = f"""# Wonderland Spark Runtime
# {name}

vmType: "vz"

arch: "aarch64"

cpus: 2

memory: "2GiB"

disk: "10GiB"

images:
  - location: "https://dl-cdn.alpinelinux.org/alpine/v3.20/releases/aarch64/alpine-virt-3.20.3-aarch64.iso"

mounts:
  - location: "{self.root}/Crystal/us/workspace/shared"
    mountPoint: "/mnt/shared"
    writable: true

  - location: "{self.root}/Crystal/us/workspace/{owner_path}"
    mountPoint: "/mnt/user"
    writable: true


containerd:
  system: false
  user: true


env:
  WL_SPARK_ID: "{name}"
  WL_OWNER: "{owner}"
"""

        target = (
            self.spark_dir /
            f"{name}.lima.yaml"
        )

        target.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        target.write_text(yaml)


        return {
            "spark": name,
            "owner": owner,
            "profile": str(target),
            "timestamp": datetime.now(UTC).isoformat(),
            "status": "READY",
        }


    def certify(self, items):

        artifact = {
            "component": "spark-runtime-foundation",
            "version": "0.1",
            "timestamp": datetime.now(UTC).isoformat(),
            "sparks": items,
            "status": "CERTIFIED",
        }

        path = (
            self.evidence_dir /
            "spark-runtime-certification.json"
        )

        path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        path.write_text(
            json.dumps(
                artifact,
                indent=2,
            )
        )

        return path
