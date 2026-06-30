#!/usr/bin/env bash
set -euo pipefail

wl_registry_root() {
  printf '%s\n' "${WL_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
}

wl_registry_file() {
  printf '%s\n' "$(wl_registry_root)/vault/05-Registry/command-registry.tsv"
}

wl_registry_docs_file() {
  printf '%s\n' "$(wl_registry_root)/vault/05-Registry/command-registry.md"
}
