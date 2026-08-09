#!/bin/sh
set -eu

echo "=== Alpine Spark Bootstrap v1 ==="

apk update

apk add \
    containerd \
    nerdctl \
    fuse-overlayfs \
    slirp4netns

echo "Spark runtime installed"

mkdir -p /etc/wonderland

cat > /etc/wonderland/spark.json <<EOF
{
  "runtime": "alpine-spark-v1",
  "status": "initialized"
}
EOF

echo "Spark bootstrap complete"
