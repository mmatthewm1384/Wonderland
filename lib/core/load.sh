#!/usr/bin/env bash

: "${WL_HOME:=$HOME/Wonderland}"

for lib in \
  "$WL_HOME/lib/core/health.sh" \
  "$WL_HOME/lib/core/health-v2.sh" \
  "$WL_HOME/lib/core/health-state.sh" \
  "$WL_HOME/lib/core/context.sh" \
  "$WL_HOME/lib/core/json.sh" \
  "$WL_HOME/lib/core/runtime.sh" \
  "$WL_HOME/lib/core/services.sh" \
  "$WL_HOME/lib/core/storage.sh" \
  "$WL_HOME/lib/core/capability.sh" \
  "$WL_HOME/lib/core/profile.sh" \
  "$WL_HOME/lib/core/state.sh"
do
  [[ -f "$lib" ]] && source "$lib"
done
