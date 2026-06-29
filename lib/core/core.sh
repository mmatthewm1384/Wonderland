#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/errors.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/output.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/env.sh"

wl_init_env

source "$WL_ROOT/lib/core/json.sh"
source "$WL_ROOT/lib/core/artifacts.sh"
source "$WL_ROOT/lib/core/runtime.sh"
source "$WL_ROOT/lib/core/validation.sh"
source "$WL_ROOT/lib/core/release.sh"
source "$WL_ROOT/lib/core/boot.sh"
source "$WL_ROOT/lib/core/baseline.sh"
source "$WL_ROOT/lib/core/handoff.sh"
source "$WL_ROOT/lib/core/certify.sh"
source "$WL_ROOT/lib/core/checkpoint.sh"
source "$WL_ROOT/lib/core/release_paths.sh"
source "$WL_ROOT/lib/core/release_history.sh"
source "$WL_ROOT/lib/core/release_manifest.sh"
source "$WL_ROOT/lib/core/release_command.sh"
source "$WL_ROOT/lib/core/start.sh"
source "$WL_ROOT/lib/core/command_inventory.sh"
source "$WL_ROOT/lib/core/command_registry.sh"
