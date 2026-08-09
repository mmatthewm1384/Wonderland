#!/usr/bin/env python3

import json
import sys
from pathlib import Path
from datetime import datetime, timezone
import secrets


def fail(msg):
    print(f"[FAIL] {msg}")
    sys.exit(1)


def main():

    if len(sys.argv) != 2:
        fail("usage: certify-spark.py <spark-directory>")

    spark_dir = Path(sys.argv[1])

    manifest = spark_dir / "manifest.yaml"
    metadata = spark_dir / "metadata.json"
    lima = spark_dir / "lima.yaml"

    if not manifest.exists():
        fail("missing manifest.yaml")

    if not metadata.exists():
        fail("missing metadata.json")

    if not lima.exists():
        fail("missing lima.yaml")


    import yaml

    with open(manifest) as f:
        manifest_data = yaml.safe_load(f)

    if "metadata" not in manifest_data:
        fail("manifest missing metadata")

    if "id" not in manifest_data["metadata"]:
        fail("manifest missing spark identity")

    spark_id = manifest_data["metadata"]["id"]
    spark_version = manifest_data["metadata"].get("version", 1)

    image_path = (
        manifest_data
        ["spec"]
        ["image"]
        ["path"]
    )

    checks = {
        "manifest": "PASS",
        "metadata": "PASS",
        "lima_profile": "PASS",
    }


    if image_path and Path(image_path).exists():
        checks["image_exists"] = "PASS"
    else:
        checks["image_exists"] = "FAIL"


    status = (
        "CERTIFIED"
        if all(v == "PASS" for v in checks.values())
        else "FAILED"
    )


    certificate = {
        "apiVersion": "spark.wonderland/v1",
        "kind": "SparkCertificate",
        "schemaVersion": 1,

        "certificateId": (
            "cert-"
            + secrets.token_hex(8)
        ),

        "spark": {
            "id": spark_id,
            "version": spark_version
        },

        "checks": checks,

        "evidence": [
            "manifest.yaml",
            "metadata.json",
            "lima.yaml"
        ],

        "verified": {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "tool": "spark-certifier-v1.1"
        },

        "status": status
    }


    output = spark_dir / "certification.json"

    with open(output, "w") as f:
        json.dump(
            certificate,
            f,
            indent=2
        )


    print(f"[{status}] Spark certification")
    print(output)


if __name__ == "__main__":
    main()
