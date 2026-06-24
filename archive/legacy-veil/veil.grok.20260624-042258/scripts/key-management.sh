#!/bin/bash
set -euo pipefail
echo "=== Age Key Management ==="
age-keygen -o age-key.txt
echo "New key generated. Use in open.sh with -i age-key.txt."
