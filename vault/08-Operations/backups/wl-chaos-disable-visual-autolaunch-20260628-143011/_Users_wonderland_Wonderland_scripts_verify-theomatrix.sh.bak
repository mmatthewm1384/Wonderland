#!/usr/bin/env bash
set -euo pipefail
root="${1:-$(pwd)}"
required=(
  "PROJECT-INSTRUCTIONS.md"
  "README.md"
  "shared/theme/WonderlandColors.swift"
  "shared/motion/WaveDriftEngine.swift"
  "shared/effects/AttachedHookShape.swift"
  "apps/wl-matrix/Sources/MatrixAtomDestroyerView.swift"
  "apps/wl-spin-city/Sources/SpinCityView.swift"
  "apps/wl-agitate/Sources/AgitateWavesView.swift"
  "apps/atom-slam/Sources/AtomSlamView.swift"
  "apps/fluderation/Sources/FluderationView.swift"
  "apps/spin-the-city/Sources/SpinTheCityView.swift"
  "docs/spin-the-city.md"
)
for f in "${required[@]}"; do
  if [[ -f "$root/$f" ]]; then
    echo "PASS $f"
  else
    echo "FAIL $f"
    exit 1
  fi
done
echo "RESULT PASS"
