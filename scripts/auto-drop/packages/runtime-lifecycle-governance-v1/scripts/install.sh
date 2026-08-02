#!/bin/sh
set -eu

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

TARGET="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/lifecycle.py"

mkdir -p "$(dirname "$TARGET")"

cat > "$TARGET" <<'PY'
class RuntimeLifecycle:

    def __init__(
        self,
        resolver,
        validator,
        evidence
    ):
        self.resolver = resolver
        self.validator = validator
        self.evidence = evidence


    def execute(
        self,
        action,
        target=None
    ):

        resolved = self.resolver.resolve(
            target
        )

        validation = self.validator.validate(
            resolved
        )

        if not validation["valid"]:
            raise RuntimeError(
                validation["errors"]
            )


        adapter = resolved["adapter"]

        handler = getattr(
            adapter,
            action,
            None
        )

        if handler is None:
            raise RuntimeError(
                f"unsupported action: {action}"
            )


        result = handler()


        self.evidence.collect(
            target,
            adapter.__class__.__name__,
            result
        )


        return result
PY

echo "runtime lifecycle governance installed"
