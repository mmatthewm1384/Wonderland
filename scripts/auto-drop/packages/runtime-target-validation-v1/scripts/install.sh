#!/bin/sh
set -eu

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/targets/validator.py"

mkdir -p "$(dirname "$TARGET")"

cat > "$TARGET" <<'PY'
class RuntimeTargetValidator:

    def validate(self, target):

        errors = []

        if not target:
            errors.append(
                "target_missing"
            )
            return {
                "valid": False,
                "errors": errors
            }

        if "adapter" not in target:
            errors.append(
                "adapter_missing"
            )

        if "instance" not in target:
            errors.append(
                "instance_missing"
            )

        if "capabilities" not in target:
            errors.append(
                "capabilities_missing"
            )

        return {
            "valid": len(errors) == 0,
            "errors": errors
        }
PY

echo "runtime target validator installed"
